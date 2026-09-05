#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"
require "open3"
require_relative "report_contracts"

ROOT = Pathname.new(__dir__).join("..").expand_path
TODAY = Date.today
REPORT_RULES_EFFECTIVE_FROM = Date.new(2026, 9, 3)
ERRORS = []
WARNINGS = []

def error(message)
  ERRORS << message
end

def warning(message)
  WARNINGS << message
end

def load_yaml(relative_path)
  YAML.safe_load(
    File.read(ROOT.join(relative_path).to_s),
    permitted_classes: [Date, Time],
    aliases: true
  )
rescue StandardError => e
  error("#{relative_path}: YAML invalide (#{e.message})")
  {}
end

def date_value(value, context)
  return value if value.is_a?(Date)
  return Date.parse(value) if value.is_a?(String)

  error("#{context}: date absente ou invalide")
  nil
rescue Date::Error
  error("#{context}: date invalide #{value.inspect}")
  nil
end

def duplicates(values)
  values.compact.group_by(&:itself).select { |_value, items| items.length > 1 }.keys
end

def validate_sources
  data = load_yaml("state/sources.yaml")
  sources = data.fetch("sources", [])
  required = %w[id name type url topics cadence reliability fallback last_attempt last_success last_item_seen status notes]
  statuses = %w[not_checked ok degraded failed]

  error("state/sources.yaml: schema_version doit valoir 2") unless data["schema_version"] == 2
  duplicates(sources.map { |source| source["id"] }).each do |id|
    error("state/sources.yaml: identifiant de source dupliqué #{id}")
  end

  sources.each do |source|
    id = source["id"] || "source sans id"
    missing = required.reject { |field| source.key?(field) }
    error("state/sources.yaml: #{id}, champs manquants: #{missing.join(', ')}") unless missing.empty?
    error("state/sources.yaml: #{id}, URL non HTTP(S)") unless source["url"].to_s.match?(%r{\Ahttps?://})
    error("state/sources.yaml: #{id}, statut invalide #{source['status'].inspect}") unless statuses.include?(source["status"])

    attempt = source["last_attempt"] && date_value(source["last_attempt"], "#{id}.last_attempt")
    success = source["last_success"] && date_value(source["last_success"], "#{id}.last_success")
    error("state/sources.yaml: #{id}, last_success postérieur à last_attempt") if attempt && success && success > attempt
    error("state/sources.yaml: #{id}, statut ok sans last_success") if source["status"] == "ok" && success.nil?
  end

  requirements = data.fetch("coverage_requirements", {})
  expected_domains = %w[AWS GCP IA]
  expected_lanes = %w[releases_features security lifecycle_deprecations availability_quotas_costs]
  error("state/sources.yaml: domaines de couverture attendus AWS, GCP et IA") unless requirements.keys.sort == expected_domains.sort

  known_ids = sources.map { |source| source["id"] }
  requirements.each do |domain, lanes|
    missing_lanes = expected_lanes.reject { |lane| lanes.key?(lane) }
    error("state/sources.yaml: #{domain}, voies manquantes: #{missing_lanes.join(', ')}") unless missing_lanes.empty?
    lanes.each do |lane, ids|
      error("state/sources.yaml: #{domain}/#{lane}, aucune source") unless ids.is_a?(Array) && !ids.empty?
      Array(ids).each do |id|
        error("state/sources.yaml: #{domain}/#{lane}, source inconnue #{id}") unless known_ids.include?(id)
      end
    end
  end

  [data, sources]
end

def validate_signals
  data = load_yaml("state/signals.yaml")
  signals = data.fetch("signals", [])
  required = %w[id canonical_url subject product_version environment first_seen last_seen status decision owner due_date deliverables publication discard_reason]
  statuses = %w[new open closed deferred discarded]
  decisions = %w[monitor qualify test adopt avoid]
  dimensions = %w[impact_architectural urgence pertinence_stack confiance]
  effective_from = date_value(data.dig("scoring_policy", "effective_from"), "scoring_policy.effective_from")
  baseline, _stderr, baseline_status = Open3.capture3("git", "show", "HEAD:state/signals.yaml", chdir: ROOT.to_s)
  baseline_data = baseline_status.success? ? YAML.safe_load(baseline, permitted_classes: [Date, Time], aliases: true) : {}
  baseline_ids = (baseline_data || {}).fetch("signals", []).map { |signal| signal["id"] }

  error("state/signals.yaml: schema_version doit valoir 2") unless data["schema_version"] == 2
  duplicates(signals.map { |signal| signal["id"] }).each do |id|
    error("state/signals.yaml: identifiant de signal dupliqué #{id}")
  end

  by_url = signals.group_by { |signal| signal["canonical_url"] }.select { |url, items| url && items.length > 1 }
  by_url.each do |url, items|
    next if items.all? { |item| item["allow_shared_canonical_url"] == true }

    error("state/signals.yaml: URL canonique dupliquée sans justification #{url}")
  end

  signals.each do |signal|
    id = signal["id"] || "signal sans id"
    error("#{id}: scoring_note requis pour un nouveau signal") if !baseline_ids.include?(id) && signal["scoring_note"].to_s.strip.empty?
    missing = required.reject { |field| signal.key?(field) }
    error("state/signals.yaml: #{id}, champs manquants: #{missing.join(', ')}") unless missing.empty?
    error("state/signals.yaml: #{id}, format d'identifiant invalide") unless id.match?(/\ASIG-\d{4}-\d{2}-\d{2}-\d{3}\z/)
    error("state/signals.yaml: #{id}, statut invalide #{signal['status'].inspect}") unless statuses.include?(signal["status"])
    error("state/signals.yaml: #{id}, décision invalide #{signal['decision'].inspect}") unless decisions.include?(signal["decision"])

    first_seen = date_value(signal["first_seen"], "#{id}.first_seen")
    last_seen = date_value(signal["last_seen"], "#{id}.last_seen")
    due_date = date_value(signal["due_date"], "#{id}.due_date")
    error("state/signals.yaml: #{id}, last_seen antérieur à first_seen") if first_seen && last_seen && last_seen < first_seen

    if effective_from && first_seen && first_seen >= effective_from
      dimensions.each do |dimension|
        value = signal[dimension]
        unknown_relevance = dimension == "pertinence_stack" && value == "inconnu" && !signal["scoring_note"].to_s.strip.empty?
        error("state/signals.yaml: #{id}, #{dimension} doit être noté de 1 à 5 (pertinence inconnue justifiée admise)") unless unknown_relevance || (value.is_a?(Integer) && value.between?(1, 5))
      end
    end

    if %w[new open].include?(signal["status"]) && due_date && due_date <= TODAY
      error("state/signals.yaml: #{id}, échéance active atteinte le #{due_date}")
    end

    if %w[closed deferred discarded].include?(signal["status"])
      error("state/signals.yaml: #{id}, last_reviewed requis pour le statut #{signal['status']}") unless signal["last_reviewed"]
      error("state/signals.yaml: #{id}, review_note requis pour le statut #{signal['status']}") if signal["review_note"].to_s.strip.empty?
    end

    Array(signal["deliverables"]).each do |deliverable|
      error("state/signals.yaml: #{id}, livrable absent #{deliverable}") unless ROOT.join(deliverable).file?
    end
  end

  signals
end

def validate_local_links
  %w[README.md docs/catalogue.md docs/rapports.md].each do |relative_path|
    path = ROOT.join(relative_path)
    text = path.read
    text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |target|
      clean = target.sub(/\A<|>\z/, "").split("#", 2).first
      next if clean.empty? || clean.match?(%r{\A(?:https?://|mailto:)})

      resolved = path.dirname.join(clean).cleanpath
      error("#{relative_path}: lien local absent #{target}") unless resolved.exist?
    end
  end

  reports_index = ROOT.join("docs/rapports.md").read
  Dir.glob(ROOT.join("dist/*/*.md").to_s).sort.each do |path|
    relative = Pathname.new(path).relative_path_from(ROOT).to_s
    error("docs/rapports.md: livrable non indexé #{relative}") unless reports_index.include?("../#{relative}")
  end
end

def validate_report(relative_path, source_data, sources)
  path = ROOT.join(relative_path).cleanpath
  return error("rapport hors du dépôt: #{relative_path}") unless path.to_s.start_with?(ROOT.to_s + File::SEPARATOR)
  return error("rapport absent: #{relative_path}") unless path.file?

  text = path.read
  return error("rapport vide: #{relative_path}") if text.strip.empty?

  previous, _stderr, status = Open3.capture3("git", "show", "HEAD:#{path.relative_path_from(ROOT)}", chdir: ROOT.to_s)
  modern = text.include?("<!-- watchtower:2 -->")
  if !modern && (!status.success? || previous.include?("<!-- watchtower:2 -->"))
    error("#{relative_path}: marqueur watchtower:2 requis pour un nouveau rapport ou un rapport déjà migré")
  end
  if modern
    validate_contract(text, path, ROOT)
    return
  end

  warning("#{relative_path}: contrat historique ; exigences version 2 non appliquées")
  if path.basename.to_s.start_with?("carte-")
    validate_card(text, relative_path, modern: false)
    return
  elsif path.basename.to_s.start_with?("classement-mensuel-")
    validate_monthly_sections(text, relative_path)
    return
  elsif path.basename.to_s != "radar-architecture.md"
    return error("#{relative_path}: type de rapport inconnu")
  end

  %w[Vue\ d’ensemble Sujets\ écartés Sources\ consultées Sources\ en\ échec].each do |section|
    error("#{relative_path}: section manquante #{section.tr('\\', '')}") unless text.match?(/^## #{section.tr('\\', '')}$/)
  end

  return unless path.basename.to_s == "radar-architecture.md"

  rows = text.lines.select { |line| line.start_with?("| [") }
  topics = text.scan(/^## \[/).length
  error("#{relative_path}: #{topics} fiches mais #{rows.length} lignes de vue d'ensemble") unless rows.length == topics

  oss_count = rows.count { |line| line.match?(/Nouveau projet OSS/i) }
  minimum = (topics / 3.0).ceil
  exception = text.match?(/Exception quota OSS\s*:/i)
  if topics.positive? && oss_count < minimum && !exception
    error("#{relative_path}: quota OSS insuffisant #{oss_count}/#{topics}, minimum #{minimum} ou exception motivée")
  end

  sources_section = text.split(/^## Sources consultées$/, 2)[1].to_s.split(/^## /, 2).first.to_s
  %w[AWS GCP IA].each do |domain|
    coverage_line = /^[^\n]*\b#{Regexp.escape(domain)}\b[^\n]*(?:signal retenu|aucun changement retenu|échec)/i
    unless sources_section.match?(coverage_line)
      error("#{relative_path}: preuve de couverture #{domain} absente")
    end
  end
  error("#{relative_path}: borne de reprise absente des sources consultées") unless sources_section.match?(/borne de reprise/i)

  report_date = path.parent.basename.to_s
  return unless report_date.match?(/\A\d{4}-\d{2}-\d{2}\z/)

  date = Date.parse(report_date)
  requirements = source_data.fetch("coverage_requirements", {})
  source_by_id = sources.each_with_object({}) { |source, memo| memo[source["id"]] = source }
  requirements.each do |domain, lanes|
    lanes.each do |lane, ids|
      covered = Array(ids).any? do |id|
        source = source_by_id[id]
        attempt = source && source["last_attempt"]
        attempt_date = attempt && date_value(attempt, "#{id}.last_attempt")
        attempt_date && attempt_date >= date && source["status"] != "not_checked"
      end
      error("#{relative_path}: journal de collecte incomplet pour #{domain}/#{lane}") unless covered
    end
  end
end

def validate_daily_freshness
  dates = Dir.glob(ROOT.join("dist/*/radar-architecture.md").to_s).map do |path|
    value = Pathname.new(path).parent.basename.to_s
    Date.parse(value) if value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
  rescue Date::Error
    nil
  end.compact

  return error("aucun radar daté disponible pour le contrôle quotidien") if dates.empty?

  latest = dates.max
  error("fraîcheur quotidienne: dernier radar #{latest}, attendu au plus tôt #{TODAY - 1}") if latest < TODAY - 1
end

if $PROGRAM_NAME == __FILE__
report_index = ARGV.index("--report")
report = report_index && ARGV[report_index + 1]
error("--report exige un chemin") if report_index && report.nil?

source_data, sources = validate_sources
validate_signals
validate_local_links

validated_reports = Dir.glob(ROOT.join("dist/*/*.md").to_s).sort.select do |path|
  date = Pathname.new(path).parent.basename.to_s
  date.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.parse(date) >= REPORT_RULES_EFFECTIVE_FROM
end.map do |path|
  Pathname.new(path).relative_path_from(ROOT).to_s
end

validated_reports.each { |path| validate_report(path, source_data, sources) }
validate_monthly_editions(ROOT)
validate_report(report, source_data, sources) if report && !validated_reports.include?(report)
validate_daily_freshness if ARGV.include?("--daily")

WARNINGS.each { |message| warn("AVERTISSEMENT: #{message}") }
ERRORS.each { |message| warn("ERREUR: #{message}") }

if ERRORS.empty?
  puts "Validation Architecture Watchtower réussie."
  exit 0
end

warn("Validation Architecture Watchtower échouée: #{ERRORS.length} erreur(s).")
exit 1
end
