#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "digest"
require "open3"
require "optparse"
require "pathname"
require "rbconfig"
require "tempfile"
require "yaml"
require_relative "prepare_radar_context"
require_relative "radar_event_log"
require_relative "report_token_usage"
require_relative "radar_selection"

ROOT = Pathname.new(__dir__).join("..").expand_path

def changed_paths(root)
  porcelain, status = Open3.capture2("git", "status", "--porcelain=v1", "--untracked-files=all", "-z", chdir: root.to_s)
  abort "Impossible de contrôler les changements" unless status.success?
  porcelain.split("\0").map { |entry| entry.length >= 4 ? entry[3..] : nil }.compact
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

def run_codex(command, prompt, live_log, phase)
  live_log.phase(phase)
  usage = nil
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
  end
  usage
end

options = { date: Date.today, commit: true, codex: ENV.fetch("CODEX_BIN", "codex"), replace: false }
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
manifest = ROOT.join("state", "radar-runs", "#{options[:date].iso8601}.yaml")
abort "La date du radar ne peut pas être future: #{options[:date]}" if options[:date] > Date.today
if report.exist? && !options[:replace]
  abort "Radar déjà présent: #{report.relative_path_from(ROOT)} (utiliser --replace pour une régénération explicite)"
end
abort "--replace exige un radar existant: #{report.relative_path_from(ROOT)}" if options[:replace] && !report.file?
abort "Manifest déjà présent sans radar: #{manifest.relative_path_from(ROOT)}" if manifest.exist? && !report.exist?

status_before, status = Open3.capture2("git", "status", "--porcelain", chdir: ROOT.to_s)
abort "Impossible de lire l’état Git" unless status.success?
abort "Le dépôt doit être propre avant une exécution orchestrée" unless status_before.empty?

head_before, status = Open3.capture2("git", "rev-parse", "HEAD", chdir: ROOT.to_s)
abort "Impossible de lire HEAD" unless status.success?
head_before = head_before.strip

live_log = WatchtowerRadarEventLog::Renderer.new
live_log.phase("Préparation du contexte local et du plan de collecte")
prepared_context = JSON.generate(WatchtowerRadarContext.build(root: ROOT, date: options[:date]))
radar_prompt = ROOT.join("radar-architecture.md").read
qualification_radar_prompt = radar_prompt.split(/^## Livrable concis/, 2).first
report_contract = ROOT.join("docs/contrats-veille.md").read
qualification_prompt = <<~PROMPT
  watchtower:orchestrated watchtower:qualify
  Qualifie le radar défini ci-dessous pour le #{options[:date].iso8601}.
  Traite d’abord toutes les échéances, réalise le contrôle primaire, la découverte et la qualification,
  puis écris uniquement #{manifest.relative_path_from(ROOT)} et les mises à jour factuelles de
  state/sources.yaml, state/signals.yaml ou state/feedback.yaml. Ne rédige ni ne modifie le rapport,
  README.md, docs/catalogue.md ou docs/rapports.md. Ne crée aucun commit.

  Le manifest doit suivre exactement le schéma du contrat, contenir tous les candidats examinés et
  ne doit pas renseigner selection_status, rank, selection_reason ni le bloc selection : ils sont
  réservés au calcul Ruby. Ne crée pas encore de signal pour un nouveau candidat ; state/signals.yaml
  ne change dans cette phase que pour traiter les échéances de signaux existants. Tout source_id
  déclaré doit exister dans state/sources.yaml ; ajoute une
  source canonique qualifiée au registre si nécessaire. Utilise le plan de collecte préparé, n’ouvre
  chaque URL qu’une fois et consigne toute période non close.

  <radar-prompt>
  #{qualification_radar_prompt}
  </radar-prompt>

  <report-contract>
  #{report_contract}
  </report-contract>

  <watchtower:prepared-context>
  #{prepared_context}
  </watchtower:prepared-context>
PROMPT

command = [options[:codex], "exec", "--json", "-C", ROOT.to_s]
command.concat(["--model", options[:model]]) if options[:model]
qualification_usage = run_codex(command, qualification_prompt, live_log, "Qualification structurée démarrée")

head_after_qualification, status = Open3.capture2("git", "rev-parse", "HEAD", chdir: ROOT.to_s)
abort "Impossible de relire HEAD" unless status.success?
abort "Codex a créé un commit pendant la qualification" unless head_after_qualification.strip == head_before
abort "Manifest attendu absent: #{manifest.relative_path_from(ROOT)}" unless manifest.file?
qualification_allowed = [
  manifest.relative_path_from(ROOT).to_s,
  "state/feedback.yaml",
  "state/signals.yaml",
  "state/sources.yaml"
]
qualification_unexpected = changed_paths(ROOT) - qualification_allowed
abort "Changements hors qualification: #{qualification_unexpected.join(', ')}" unless qualification_unexpected.empty?

live_log.phase("Calcul déterministe de la sélection")
selected = system(
  RbConfig.ruby,
  ROOT.join("scripts/select_radar_candidates.rb").to_s,
  "--manifest", manifest.to_s,
  "--signals", ROOT.join("state/signals.yaml").to_s,
  chdir: ROOT.to_s
)
abort "Calcul de sélection échoué" unless selected
manifest_data = YAML.safe_load(manifest.read, permitted_classes: [Date, Time], aliases: false) || {}
selection_errors = WatchtowerRadarSelection.validate(manifest_data, date: options[:date], selected: true)
abort "Manifest sélectionné invalide: #{selection_errors.join('; ')}" unless selection_errors.empty?
manifest_digest = Digest::SHA256.hexdigest(manifest.read)

writing_context = JSON.generate(WatchtowerRadarContext.build(root: ROOT, date: options[:date]))
writing_prompt = <<~PROMPT
  watchtower:orchestrated watchtower:write
  Rédige le radar du #{options[:date].iso8601} à partir de la sélection verrouillée ci-dessous.
  Produis #{report.relative_path_from(ROOT)}, mets à jour state/signals.yaml, docs/catalogue.md,
  docs/rapports.md et README.md selon le prompt, et ne modifie pas le manifest ni la sélection.
  N’effectue aucune nouvelle collecte web. Seuls les candidats selection_status=selected deviennent
  des fiches, dans l’ordre de rank. Reprends exactement leur nom, URL, nature, novelty et champ fact,
  ainsi que toutes leurs URL de preuve primaire. Reprends exactement la couverture du manifest dans
  le bloc watchtower-couverture et chaque source_failure, période et conséquence dans Sources en
  échec. Si oss_exception existe,
  écris `Exception quota OSS : <valeur exacte>` dans Sujets écartés. Laisse les tokens sur la variante
  non disponible. Pour les signaux, mappe les nouveautés vers `nouveau_projet_oss`,
  `nouveau_hors_oss` ou `mise_a_jour` et recopie les champs contrôlés du candidat. Ne lance pas le
  validateur et ne crée aucun commit : l’orchestrateur s’en charge.

  <radar-prompt>
  #{radar_prompt}
  </radar-prompt>

  <report-contract>
  #{report_contract}
  </report-contract>

  <watchtower:prepared-context>
  #{writing_context}
  </watchtower:prepared-context>

  <watchtower:selected-manifest>
  #{JSON.generate(manifest_data)}
  </watchtower:selected-manifest>
PROMPT

writing_usage = run_codex(command, writing_prompt, live_log, "Rédaction verrouillée démarrée")
abort "Le manifest a été modifié pendant la rédaction" unless Digest::SHA256.hexdigest(manifest.read) == manifest_digest
usage = WatchtowerTokenUsage.sum(qualification_usage, writing_usage)

live_log.phase("Métriques récupérées — #{WatchtowerTokenUsage.render(usage)}")

head_after, status = Open3.capture2("git", "rev-parse", "HEAD", chdir: ROOT.to_s)
abort "Impossible de relire HEAD" unless status.success?
abort "Codex a créé un commit malgré le mode orchestré; métriques non injectées" unless head_after.strip == head_before
abort "Radar attendu absent: #{report.relative_path_from(ROOT)}" unless report.file?

budget_path = ROOT.join("state/budget.yaml")
if budget_path.file?
  budget = (YAML.safe_load(budget_path.read, permitted_classes: [Date]) || {})["radar"] || {}
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
end

generation_duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - generation_started_at).ceil
WatchtowerTokenUsage.inject(report, usage, duration_seconds: generation_duration)

relative_report = report.relative_path_from(ROOT).to_s
live_log.phase("Validation démarrée — #{relative_report}")
validated = system(RbConfig.ruby, ROOT.join("scripts/validate_watchtower.rb").to_s, "--report", relative_report, chdir: ROOT.to_s)
abort "Validation du radar échouée" unless validated
live_log.phase("Validation terminée")

allowed = [
  relative_report,
  "README.md",
  "docs/catalogue.md",
  "docs/rapports.md",
  "state/feedback.yaml",
  manifest.relative_path_from(ROOT).to_s,
  "state/signals.yaml",
  "state/sources.yaml"
]
porcelain, status = Open3.capture2("git", "status", "--porcelain=v1", "--untracked-files=all", "-z", chdir: ROOT.to_s)
abort "Impossible de contrôler les changements" unless status.success?
changed = porcelain.split("\0").map { |entry| entry.length >= 4 ? entry[3..] : nil }.compact
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
