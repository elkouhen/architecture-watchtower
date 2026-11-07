#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "digest"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "pathname"
require "rbconfig"
require "tempfile"
require "yaml"
require_relative "contract_sections"
require_relative "index_reports"
require_relative "prepare_radar_context"
require_relative "radar_collection"
require_relative "radar_event_log"
require_relative "radar_selection"
require_relative "radar_signal_registry"
require_relative "radar_source_registry"
require_relative "report_token_usage"

ROOT = Pathname.new(__dir__).join("..").expand_path

# Sections du contrat injectées par phase : le reste du contrat n’est pas lu par le modèle.
QUALIFICATION_CONTRACT_SECTIONS = [
  "Preuves et dates", "Repères des notes", "Couverture du radar",
  "Algorithme Scanner", "1. Scanner", "Manifest de qualification", "2. Filtrer", "3. Vérifier", "4. Publier",
  "Budget de contexte orchestré"
].freeze
WRITING_CONTRACT_SECTIONS = ["Preuves et dates", "Couverture du radar", "4. Publier"].freeze
WRITING_PROMPT_SECTIONS = ["But et périmètre", "Livrable concis"].freeze
METRIC_ITEM_TYPES = %w[command_execution web_search file_change mcp_tool_call agent_message].freeze

def changed_paths(root)
  porcelain, status = Open3.capture2("git", "status", "--porcelain=v1", "--untracked-files=all", "-z", chdir: root.to_s)
  abort "Impossible de contrôler les changements" unless status.success?
  porcelain.split("\0").map { |entry| entry.length >= 4 ? entry[3..-1] : nil }.compact
end

def git_head(root)
  head, status = Open3.capture2("git", "rev-parse", "HEAD", chdir: root.to_s)
  abort "Impossible de lire HEAD" unless status.success?
  head.strip
end

def extract_usage(events_path)
  WatchtowerTokenUsage.extract(events_path)
rescue WatchtowerTokenUsage::Error
  id = WatchtowerTokenUsage.thread_id(events_path)
  session = WatchtowerTokenUsage.session_for(id)
  abort "Aucune métrique de tour exploitable pour la session #{id || 'inconnue'}" unless session
  begin
    WatchtowerTokenUsage.extract(session)
  rescue WatchtowerTokenUsage::Error => e
    abort "Métriques de session invalides: #{e.message}"
  end
end

def count_items(events_path)
  counts = Hash.new(0)
  File.foreach(events_path) do |line|
    event = JSON.parse(line)
    next unless event["type"] == "item.completed"

    type = event.dig("item", "type").to_s.downcase
    counts[type] += 1 if METRIC_ITEM_TYPES.include?(type)
  rescue JSON::ParserError
    next
  end
  counts
end

def run_codex(command, prompt, live_log, phase)
  live_log.phase(phase)
  usage = nil
  items = nil
  Tempfile.create(["watchtower-codex-", ".jsonl"]) do |events|
    child_status = nil
    Open3.popen3(*(command + [prompt])) do |stdin, stdout, stderr, wait_thread|
      stdin.close
      stderr_thread = Thread.new { stderr.each_line { |line| warn line } }
      stdout.each_line do |line|
        events.write(line)
        live_log.consume(line)
      end
      stderr_thread.join
      child_status = wait_thread.value
    end
    abort "Codex a échoué avec le statut #{child_status.exitstatus}" unless child_status.success?
    events.flush
    usage = extract_usage(events.path)
    items = count_items(events.path)
  end
  { usage: usage, items: items }
end

# Contrôle a priori : la taille du préfixe injecté est connue avant tout appel Codex.
def preflight(prompt, parts, phase, budget, live_log)
  breakdown = parts.map { |name, text| "#{name} #{text.to_s.bytesize}" }.join(", ")
  live_log.phase("Préfixe #{phase} : #{prompt.bytesize} octets (#{breakdown})")
  limit = budget["max_prompt_bytes"]
  return unless limit && prompt.bytesize > limit

  abort "Préfixe #{phase} de #{prompt.bytesize} octets au-delà de max_prompt_bytes=#{limit} (state/budget.yaml) ; " \
    "aucun appel Codex lancé. Réduire le contexte avant de relancer."
end

def prompt_intro(text)
  text.split(/^## /, 2).first.to_s.rstrip
end

def writing_manifest(manifest)
  candidates = Array(manifest["candidates"])
  selected = candidates.select { |candidate| candidate["selection_status"] == "selected" }.sort_by { |candidate| candidate["rank"].to_i }
  rejected = (candidates - selected).map do |candidate|
    candidate.select { |key, _value| %w[id name canonical_url novelty origin selection_reason rejection_note].include?(key) }
  end
  projection = manifest.select { |key, _value| %w[schema_version date algorithm sources coverage source_failures candidate_yield_note selection].include?(key) }
  projection.merge("candidates" => selected, "rejected_candidates" => rejected)
end

options = { date: Date.today, commit: true, codex: ENV.fetch("CODEX_BIN", "codex"), replace: false, dry_run: false }
parser = OptionParser.new do |option_parser|
  option_parser.banner = "Usage: ruby scripts/run_radar.rb [options]"
  option_parser.on("--date YYYY-MM-DD", "Date du radar") do |value|
    options[:date] = Date.iso8601(value)
  rescue ArgumentError
    raise OptionParser::InvalidArgument, "date ISO invalide: #{value}"
  end
  option_parser.on("--model MODEL", "Modèle Codex explicite") { |value| options[:model] = value }
  option_parser.on("--codex PATH", "Exécutable Codex") { |value| options[:codex] = value }
  option_parser.on("--replace", "Régénérer explicitement le radar existant de cette date") { options[:replace] = true }
  option_parser.on("--no-commit", "Injecter et valider sans commit") { options[:commit] = false }
  option_parser.on("--dry-run", "Collecter, préparer et mesurer le préfixe sans appel Codex ni écriture des registres") { options[:dry_run] = true }
  option_parser.on("-h", "--help", "Afficher cette aide") { puts option_parser; exit }
end
begin
  parser.parse!
rescue OptionParser::ParseError => e
  warn "ERREUR: #{e.message}"
  warn parser
  exit 2
end

generation_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

report = ROOT.join("dist", options[:date].iso8601, "radar-architecture.md")
relative_report = report.relative_path_from(ROOT).to_s
manifest = ROOT.join("state", "radar-runs", "#{options[:date].iso8601}.yaml")
metrics_path = ROOT.join("state", "radar-runs", "#{options[:date].iso8601}.metrics.yaml")
abort "La date du radar ne peut pas être future: #{options[:date]}" if options[:date] > Date.today
if report.exist? && !options[:replace]
  abort "Radar déjà présent: #{relative_report} (utiliser --replace pour une régénération explicite)"
end
abort "--replace exige un radar existant: #{relative_report}" if options[:replace] && !report.file?
abort "--replace exige un manifest existant: #{manifest.relative_path_from(ROOT)}" if options[:replace] && !manifest.file?
abort "Manifest déjà présent sans radar: #{manifest.relative_path_from(ROOT)}" if manifest.exist? && !report.exist?

status_before, status = Open3.capture2("git", "status", "--porcelain", chdir: ROOT.to_s)
abort "Impossible de lire l’état Git" unless status.success?
abort "Le dépôt doit être propre avant une exécution orchestrée" unless status_before.empty? || options[:dry_run]
head_before = git_head(ROOT)

budget_path = ROOT.join("state/budget.yaml")
budget = budget_path.file? ? ((YAML.safe_load(budget_path.read, permitted_classes: [Date]) || {})["radar"] || {}) : {}

live_log = WatchtowerRadarEventLog::Renderer.new
radar_prompt = ROOT.join("radar-architecture.md").read
qualification_radar_prompt = radar_prompt.split(/^## Livrable concis/, 2).first
writing_radar_prompt = "#{prompt_intro(radar_prompt)}\n\n#{WatchtowerContractSections.extract(radar_prompt, WRITING_PROMPT_SECTIONS)}"
report_contract = ROOT.join("docs/contrats-veille.md").read
qualification_contract = WatchtowerContractSections.extract(report_contract, QUALIFICATION_CONTRACT_SECTIONS)
writing_contract = WatchtowerContractSections.extract(report_contract, WRITING_CONTRACT_SECTIONS)
command = [options[:codex], "exec", "--json", "-C", ROOT.to_s]
command.concat(["--model", options[:model]]) if options[:model]
signals_path = ROOT.join("state/signals.yaml")
sources_path = ROOT.join("state/sources.yaml")
cache_dir = WatchtowerRadarContext.cache_dir(options[:date])
phases = {}
qualification_result = nil

if options[:replace]
  live_log.phase("Régénération depuis le manifest verrouillé — collecte et sélection ignorées")
  manifest_data = YAML.safe_load(manifest.read, permitted_classes: [Date, Time], aliases: false) || {}
  selection_errors = WatchtowerRadarSelection.validate(manifest_data, date: options[:date], selected: true)
  abort "Manifest sélectionné invalide: #{selection_errors.join('; ')}" unless selection_errors.empty?
  writing_context = JSON.generate({ "schema_version" => 2, "date" => options[:date].iso8601, "replacement" => true })
  writing_scope = <<~SCOPE
    Remplace uniquement #{relative_report}. Ne modifie aucun autre fichier : conserve
    le manifest, les registres sous state/, docs/catalogue.md, docs/rapports.md et README.md
    exactement dans leur état actuel.
  SCOPE
else
  live_log.phase("Traitement déterministe des échéances de signaux")
  signals_data = WatchtowerRadarSignalRegistry.load(signals_path)
  reviewed_signals = WatchtowerRadarSignalRegistry.review_due!(signals_data, date: options[:date])
  WatchtowerRadarSignalRegistry.save(signals_path, signals_data) unless reviewed_signals.empty? || options[:dry_run]
  live_log.phase("Échéances traitées : #{reviewed_signals.length} signal(aux) clos ou différé(s)")

  sources_data = WatchtowerRadarContext.load_yaml(sources_path)
  selected_sources = WatchtowerRadarContext.selected_sources(sources_data)
  live_log.phase("Collecte locale de #{selected_sources.length} source(s) vers #{cache_dir}")
  FileUtils.rm_rf(ROOT.join(cache_dir))
  collection = WatchtowerRadarCollection.collect(
    selected_sources, date: options[:date], root: ROOT, cache_dir: cache_dir, feeds: WatchtowerRadarContext.feeds(sources_data)
  )
  WatchtowerRadarCollection.update_registry(sources_path, collection, date: options[:date]) unless options[:dry_run]
  collection.each do |result|
    detail = case [result["status"], result["kind"]]
    when %w[ok feed] then "flux, #{result['items_total']} élément(s) en delta"
    when %w[ok page] then "page, #{result['chars']} caractères"
    else "échec : #{result['attempts'].map { |attempt| attempt['error'] }.join(' ; ')}"
    end
    live_log.phase("Source #{result['source_id']} — #{detail}")
  end

  live_log.phase("Préparation du contexte local")
  prepared_context = JSON.generate(
    WatchtowerRadarContext.build(root: ROOT, date: options[:date], collection: collection, reviewed_signals: reviewed_signals)
  )
  qualification_prompt = <<~PROMPT
    watchtower:orchestrated watchtower:qualify
    Qualifie le radar défini ci-dessous pour le #{options[:date].iso8601}.
    Les échéances de signaux ont déjà été traitées par script (voir reviewed_signals) : ne les retraite pas.
    Les sources ont déjà été collectées dans #{cache_dir} (voir collection dans le contexte) : lis ces
    fichiers locaux de façon ciblée (rg, sed -n) au lieu d’ouvrir les mêmes URL sur le web. Le web sert
    uniquement aux pages canoniques des candidats à vérifier et, une seule fois, à une source en échec.
    Réalise le contrôle primaire, la découverte et la qualification, puis écris uniquement
    #{manifest.relative_path_from(ROOT)} et, si nécessaire, state/sources.yaml (nouvelle source de
    qualification) ou state/feedback.yaml. Ne modifie ni state/signals.yaml, ni le rapport, ni README.md,
    ni docs/. Ne crée aucun commit.

    Le manifest suit exactement le schéma du contrat et contient tous les éléments examinés : fiche
    complète pour les candidats qui franchissent les trois filtres, fiche allégée (identité, nom, URL,
    novelty, filtres et rejection_note) pour les autres. Ne renseigne ni selection_status, ni rank, ni
    selection_reason, ni le bloc selection : ils sont calculés par script. Tout source_id déclaré doit
    exister dans state/sources.yaml. Consigne toute période non close.

    <radar-prompt>
    #{qualification_radar_prompt}
    </radar-prompt>

    <report-contract>
    #{qualification_contract}
    </report-contract>

    <watchtower:prepared-context>
    #{prepared_context}
    </watchtower:prepared-context>
  PROMPT
  preflight(
    qualification_prompt,
    { "prompt radar" => qualification_radar_prompt, "contrat" => qualification_contract, "contexte" => prepared_context },
    "qualification", budget, live_log
  )
  if options[:dry_run]
    live_log.phase("Mode dry-run : aucun appel Codex ; cache conservé dans #{cache_dir}")
    exit 0
  end
  signals_digest = Digest::SHA256.hexdigest(signals_path.read)
  qualification_result = run_codex(command, qualification_prompt, live_log, "Qualification structurée démarrée")
  phases["qualification"] = { "prompt_bytes" => qualification_prompt.bytesize }.merge(qualification_result[:items]).merge("usage" => qualification_result[:usage].transform_keys(&:to_s))

  abort "Codex a créé un commit pendant la qualification" unless git_head(ROOT) == head_before
  abort "Manifest attendu absent: #{manifest.relative_path_from(ROOT)}" unless manifest.file?
  abort "state/signals.yaml modifié par le modèle pendant la qualification" unless Digest::SHA256.hexdigest(signals_path.read) == signals_digest
  qualification_allowed = [manifest.relative_path_from(ROOT).to_s, "state/feedback.yaml", "state/signals.yaml", "state/sources.yaml"]
  qualification_unexpected = changed_paths(ROOT) - qualification_allowed
  abort "Changements hors qualification: #{qualification_unexpected.join(', ')}" unless qualification_unexpected.empty?

  live_log.phase("Calcul déterministe de la sélection")
  selected = system(
    RbConfig.ruby, ROOT.join("scripts/select_radar_candidates.rb").to_s,
    "--manifest", manifest.to_s, "--signals", signals_path.to_s, chdir: ROOT.to_s
  )
  abort "Calcul de sélection échoué" unless selected
  manifest_data = YAML.safe_load(manifest.read, permitted_classes: [Date, Time], aliases: false) || {}
  selection_errors = WatchtowerRadarSelection.validate(manifest_data, date: options[:date], selected: true)
  abort "Manifest sélectionné invalide: #{selection_errors.join('; ')}" unless selection_errors.empty?

  live_log.phase("Avancement des curseurs de sources depuis la couverture du manifest")
  Array(manifest_data["coverage"]).select { |entry| entry["complete"] == true && entry["result"] != "échec" }
                                  .flat_map { |entry| Array(entry["sources"]) }.uniq.each do |source_id|
    WatchtowerRadarSourceRegistry.update(sources_path, source_id, { "last_attempt" => options[:date].iso8601, "last_success" => options[:date].iso8601, "status" => "ok" })
  end

  selected_urls = Array(manifest_data["candidates"]).select { |candidate| candidate["selection_status"] == "selected" }.map { |candidate| candidate["canonical_url"] }
  writing_context = JSON.generate(WatchtowerRadarContext.writing(root: ROOT, date: options[:date], selected_urls: selected_urls))
  writing_scope = <<~SCOPE
    Produis #{relative_report} et mets à jour docs/catalogue.md : une ligne par sujet retenu, insérée
    après la ligne indiquée par insert_after_line (ou mise à jour de la ligne existante listée dans
    existing_rows_for_selection), sans lire le reste du fichier. Ne modifie ni le manifest, ni les
    registres sous state/, ni docs/rapports.md, ni README.md : les signaux et les index sont mis à jour
    par script après la rédaction.
  SCOPE
end

manifest_digest = Digest::SHA256.hexdigest(manifest.read)
selected_manifest = JSON.generate(writing_manifest(manifest_data))
writing_prompt = <<~PROMPT
  watchtower:orchestrated watchtower:write#{' watchtower:replace' if options[:replace]}
  Rédige le radar du #{options[:date].iso8601} à partir de la sélection verrouillée ci-dessous.
  #{writing_scope}
  N’effectue aucune nouvelle collecte web et ne relis aucun registre. Seuls les candidats de la liste
  candidates (selection_status=selected) deviennent des fiches, dans l’ordre de rank. Reprends exactement
  leur nom, URL, nature, novelty, origin et champ fact, ainsi que toutes leurs URL de preuve primaire.
  Dans la colonne Type, affiche `<nature> · <origin>` pour `Nouveau hors OSS`,
  `<nature> · Nouveau projet OSS` pour un nouveau projet OSS et `<nature> · Mise à jour` pour une mise à jour ;
  le libellé interne `Nouveau hors OSS` ne doit jamais apparaître dans le rapport. Reprends exactement la
  couverture du manifest dans le bloc watchtower-couverture et chaque source_failure, période et
  conséquence dans Sources en échec. rejected_candidates alimente Sujets écartés. Si oss_exception
  existe, écris `Exception quota OSS : <valeur exacte>` dans Sujets écartés. Si minimum_exception existe,
  écris `Exception minimum de sujets : <valeur exacte>` dans Sujets écartés. Laisse les tokens sur la
  variante non disponible. Ne lance pas le validateur et ne crée aucun commit : l’orchestrateur s’en charge.

  <radar-prompt>
  #{writing_radar_prompt}
  </radar-prompt>

  <report-contract>
  #{writing_contract}
  </report-contract>

  <watchtower:prepared-context>
  #{writing_context}
  </watchtower:prepared-context>

  <watchtower:selected-manifest>
  #{selected_manifest}
  </watchtower:selected-manifest>
PROMPT
preflight(
  writing_prompt,
  { "prompt radar" => writing_radar_prompt, "contrat" => writing_contract, "contexte" => writing_context, "sélection" => selected_manifest },
  "rédaction", budget, live_log
)

writing_result = run_codex(command, writing_prompt, live_log, "Rédaction verrouillée démarrée")
phases["writing"] = { "prompt_bytes" => writing_prompt.bytesize }.merge(writing_result[:items]).merge("usage" => writing_result[:usage].transform_keys(&:to_s))
abort "Le manifest a été modifié pendant la rédaction" unless Digest::SHA256.hexdigest(manifest.read) == manifest_digest
usage = WatchtowerTokenUsage.sum(*[qualification_result && qualification_result[:usage], writing_result[:usage]].compact)
live_log.phase("Métriques récupérées — #{WatchtowerTokenUsage.render(usage)}")

abort "Codex a créé un commit malgré le mode orchestré; métriques non injectées" unless git_head(ROOT) == head_before
abort "Radar attendu absent: #{relative_report}" unless report.file?

unless options[:replace]
  live_log.phase("Synchronisation des signaux et des index par script")
  signals_data = WatchtowerRadarSignalRegistry.load(signals_path)
  publication = options[:commit] ? "local_commit" : "pending_orchestrator_commit"
  begin
    WatchtowerRadarSignalRegistry.sync_from_manifest!(signals_data, manifest_data, report_path: relative_report, date: options[:date], publication: publication)
  rescue WatchtowerRadarSignalRegistry::Error => e
    abort "Synchronisation des signaux échouée: #{e.message}"
  end
  WatchtowerRadarSignalRegistry.save(signals_path, signals_data)
  WatchtowerReportIndex.add_radar(root: ROOT, date: options[:date])
end

reference = budget["reference_value"]
overrun_pct = budget["overrun_threshold_pct"]
if reference && overrun_pct
  billed_input = usage[:input] - usage[:cached]
  threshold = (reference * (1 + overrun_pct / 100.0)).to_i
  if billed_input > threshold
    warn "ALERTE BUDGET: entrée hors cache #{billed_input} tokens > seuil #{threshold} " \
      "(référence #{reference} + #{overrun_pct}%, state/budget.yaml)."
    Open3.capture2("git", "checkout", "--", ".", chdir: ROOT.to_s)
    Open3.capture2("git", "clean", "-fd", chdir: ROOT.to_s)
    abort "Génération annulée : dépassement de budget (#{billed_input} > #{threshold} tokens hors cache). " \
      "Aucune publication ; changements locaux annulés."
  end
end

generation_duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - generation_started_at).ceil
WatchtowerTokenUsage.inject(report, usage, duration_seconds: generation_duration)
unless options[:replace]
  metrics_path.write(YAML.dump({
    "date" => options[:date].iso8601,
    "duration_seconds" => generation_duration,
    "usage" => usage.transform_keys(&:to_s),
    "phases" => phases
  }))
end

live_log.phase("Validation démarrée — #{relative_report}")
validated = system(RbConfig.ruby, ROOT.join("scripts/validate_watchtower.rb").to_s, "--report", relative_report, chdir: ROOT.to_s)
abort "Validation du radar échouée" unless validated
live_log.phase("Validation terminée")

allowed = if options[:replace]
  [relative_report]
else
  [
    relative_report, "README.md", "docs/catalogue.md", "docs/rapports.md", "state/feedback.yaml",
    manifest.relative_path_from(ROOT).to_s, metrics_path.relative_path_from(ROOT).to_s,
    "state/signals.yaml", "state/sources.yaml"
  ]
end
changed = changed_paths(ROOT)
unexpected = changed - allowed
abort "Changements hors périmètre: #{unexpected.join(', ')}" unless unexpected.empty?
abort "Aucun changement à publier" if changed.empty?

if options[:commit]
  live_log.phase("Commit local démarré")
  system("git", "add", "--", *changed, chdir: ROOT.to_s) || abort("git add a échoué")
  message = "radar: publish #{options[:date].iso8601} architecture watch"
  system("git", "commit", "-m", message, chdir: ROOT.to_s) || abort("git commit a échoué")
  live_log.phase("Commit local terminé")
end

puts "Radar instrumenté: #{relative_report}"
puts WatchtowerTokenUsage.render(usage, duration_seconds: generation_duration)
