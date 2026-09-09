#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "open3"
require "optparse"
require "pathname"
require "rbconfig"
require "tempfile"
require "yaml"
require_relative "prepare_radar_context"
require_relative "radar_event_log"
require_relative "report_token_usage"

ROOT = Pathname.new(__dir__).join("..").expand_path

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

report = ROOT.join("dist", options[:date].iso8601, "radar-architecture.md")
abort "La date du radar ne peut pas être future: #{options[:date]}" if options[:date] > Date.today
if report.exist? && !options[:replace]
  abort "Radar déjà présent: #{report.relative_path_from(ROOT)} (utiliser --replace pour une régénération explicite)"
end
abort "--replace exige un radar existant: #{report.relative_path_from(ROOT)}" if options[:replace] && !report.file?

status_before, status = Open3.capture2("git", "status", "--porcelain", chdir: ROOT.to_s)
abort "Impossible de lire l’état Git" unless status.success?
abort "Le dépôt doit être propre avant une exécution orchestrée" unless status_before.empty?

head_before, status = Open3.capture2("git", "rev-parse", "HEAD", chdir: ROOT.to_s)
abort "Impossible de lire HEAD" unless status.success?
head_before = head_before.strip

live_log = WatchtowerRadarEventLog::Renderer.new
live_log.phase("Préparation du contexte local")
prepared_context = JSON.generate(WatchtowerRadarContext.build(root: ROOT, date: options[:date]))
radar_prompt = ROOT.join("radar-architecture.md").read
report_contract = ROOT.join("docs/contrats-veille.md").read
live_log.phase("Contexte préparé — lancement Codex pour le radar #{options[:date].iso8601}")

prompt = <<~PROMPT
  watchtower:orchestrated
  #{options[:replace] ? "Régénère explicitement et corrige" : "Exécute strictement"} le radar défini par radar-architecture.md pour le #{options[:date].iso8601}.
  Produis #{report.relative_path_from(ROOT)} et les mises à jour locales exigées par le prompt.
  Laisse la ligne de consommation sur la variante `non disponible` et ne crée aucun commit :
  l’orchestrateur injectera les métriques du tour terminé, validera puis commitera le résultat.

  Le prompt radar, le contrat commun et le contexte local préparé sont déjà inclus ci-dessous.
  Ne les relis pas sur disque. Utilise le contexte préparé pour les échéances, la déduplication,
  les bornes des sources et l’historique local ; n’ouvre un fichier local que pour appliquer une
  modification ciblée ou résoudre une incohérence précise.

  <radar-prompt>
  #{radar_prompt}
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
command << prompt

usage = nil
Tempfile.create(["watchtower-codex-", ".jsonl"]) do |events|
  child_status = nil
  Open3.popen3(*command) do |stdin, stdout, stderr, wait_thread|
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
  begin
    usage = WatchtowerTokenUsage.extract(events.path)
  rescue WatchtowerTokenUsage::Error
    id = WatchtowerTokenUsage.thread_id(events.path)
    session = WatchtowerTokenUsage.session_for(id)
    abort "Aucune métrique de tour exploitable pour la session #{id || 'inconnue'}" unless session
    begin
      usage = WatchtowerTokenUsage.extract(session)
    rescue WatchtowerTokenUsage::Error => e
      abort "Métriques de session invalides: #{e.message}"
    end
  end
end

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

WatchtowerTokenUsage.inject(report, usage)

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
puts WatchtowerTokenUsage.render(usage)
