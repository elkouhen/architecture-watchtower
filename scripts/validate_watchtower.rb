#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"
require "open3"
require_relative "report_contracts"
require_relative "radar_selection"

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

# Les registres v3 peuvent être stockés sous forme tabulaire pour ne pas
# répéter les mêmes clés dans chaque entrée YAML. Le validateur travaille
# toujours sur des hash normalisés.
def registry_records(data, collection, fields_key, context)
  records = data.fetch(collection, [])
  return records unless data["format"] == "tabular-v1"

  fields = data[fields_key]
  unless fields.is_a?(Array) && fields.all? { |field| field.is_a?(String) }
    error("#{context}: #{fields_key} requis pour le format tabulaire")
    return []
  end

  records.map.with_index do |row, index|
    unless row.is_a?(Array) && row.length == fields.length
      error("#{context}: ligne tabulaire #{index + 1} invalide")
      next {}
    end
    fields.zip(row).to_h
  end
end

def validate_sources
  data = load_yaml("state/sources.yaml")
  sources = registry_records(data, "sources", "source_fields", "state/sources.yaml")
  required = %w[id name type url topics cadence reliability fallback last_attempt last_success last_item_seen status notes]
  statuses = %w[not_checked ok degraded failed]

  error("state/sources.yaml: schema_version doit valoir 2 ou 3") unless [2, 3].include?(data["schema_version"])
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
  signals = registry_records(data, "signals", "signal_fields", "state/signals.yaml")
  required = %w[id identity_key canonical_url subject product_version environment first_seen last_seen status decision owner due_date deliverables publication discard_reason]
  statuses = %w[new open closed deferred discarded]
  decisions = %w[monitor qualify test adopt avoid]
  dimensions = %w[impact_architectural urgence pertinence_stack confiance]
  effective_from = date_value(data.dig("scoring_policy", "effective_from"), "scoring_policy.effective_from")
  baseline, _stderr, baseline_status = Open3.capture3("git", "show", "HEAD:state/signals.yaml", chdir: ROOT.to_s)
  baseline_data = baseline_status.success? ? YAML.safe_load(baseline, permitted_classes: [Date, Time], aliases: true) : {}
  baseline_ids = registry_records(baseline_data || {}, "signals", "signal_fields", "HEAD:state/signals.yaml").map { |signal| signal["id"] }

  error("state/signals.yaml: schema_version doit valoir 2 ou 3") unless [2, 3].include?(data["schema_version"])
  duplicates(signals.map { |signal| signal["id"] }).each do |id|
    error("state/signals.yaml: identifiant de signal dupliqué #{id}")
  end

  duplicates(signals.map { |signal| signal["identity_key"] }).each do |identity|
    error("state/signals.yaml: identity_key dupliquée #{identity}")
  end

  signals.each do |signal|
    id = signal["id"] || "signal sans id"
    error("#{id}: scoring_note requis pour un nouveau signal") if !baseline_ids.include?(id) && signal["scoring_note"].to_s.strip.empty?
    missing = required.reject { |field| signal.key?(field) }
    error("state/signals.yaml: #{id}, champs manquants: #{missing.join(', ')}") unless missing.empty?
    error("state/signals.yaml: #{id}, format d'identifiant invalide") unless id.match?(/\ASIG-\d{4}-\d{2}-\d{2}-\d{3}\z/)
    error("state/signals.yaml: #{id}, identity_key absente") if signal["identity_key"].to_s.strip.empty?
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

def validate_radar_manifest(path, text, sources, signals, root: ROOT)
  report_date = date_value(path.parent.basename.to_s, path.to_s)
  return unless report_date && report_date >= Date.new(2026, 9, 10)

  manifest_path = root.join("state/radar-runs", "#{report_date.iso8601}.yaml")
  return error("#{path}: manifest radar absent #{manifest_path.relative_path_from(root)}") unless manifest_path.file?

  data = YAML.safe_load(manifest_path.read, permitted_classes: [Date, Time], aliases: false) || {}
  WatchtowerRadarSelection.validate(data, date: report_date, selected: true).each do |message|
    error("#{manifest_path.relative_path_from(root)}: #{message}")
  end

  known_source_ids = sources.map { |source| source["id"] }
  declared_source_ids = data.fetch("sources", {}).values.flatten +
    Array(data["coverage"]).flat_map { |entry| Array(entry["sources"]) } +
    Array(data["candidates"]).flat_map { |candidate| Array(candidate["evidence"]).map { |proof| proof["source_id"] if proof.is_a?(Hash) } } +
    Array(data["source_failures"]).map { |failure| failure["source_id"] if failure.is_a?(Hash) }
  (declared_source_ids.compact.uniq - known_source_ids).each do |id|
    error("#{manifest_path.relative_path_from(root)}: source inconnue #{id}")
  end

  source_by_id = sources.each_with_object({}) { |source, memo| memo[source["id"]] = source }
  Array(data.dig("sources", "control")).each do |id|
    attempt = source_by_id[id] && source_by_id[id]["last_attempt"]
    attempt_date = attempt && date_value(attempt, "#{id}.last_attempt")
    error("#{manifest_path.relative_path_from(root)}: aucune tentative datée pour #{id}") unless attempt_date && attempt_date >= report_date
  end

  selected = Array(data["candidates"]).select { |candidate| candidate["selection_status"] == "selected" }.sort_by { |candidate| candidate["rank"] }
  overview = sections_of(text)["vue d’ensemble"]
  rows = table_rows(overview)
  rows.shift
  actual = rows.map do |row|
    [row[0].to_s[/\[([^\]]+)\]/, 1], row[0].to_s[/\]\((https?:\/\/[^)]+)\)/, 1], row[1]]
  end
  expected = selected.map { |candidate| [candidate["name"], candidate["canonical_url"], "#{candidate['nature']} · #{candidate['novelty']}"] }
  error("#{path}: sélection publiée différente du manifest") unless actual == expected

  selected.each do |candidate|
    error("#{path}: fait qualifié absent du rapport pour #{candidate['id']}") unless text.include?(candidate["fact"])
    Array(candidate["evidence"]).select { |proof| proof["primary"] == true }.each do |proof|
      error("#{path}: preuve primaire absente du rapport pour #{candidate['id']}") unless text.include?(proof["url"])
    end
    signal = signals.find { |item| item["identity_key"] == candidate["identity_key"] }
    if !signal
      error("#{path}: signal absent pour #{candidate['identity_key']}")
    elsif !Array(signal["deliverables"]).include?(path.relative_path_from(root).to_s)
      error("#{path}: livrable absent du signal #{signal['id']}")
    else
      expected_classification = {
        "Nouveau projet OSS" => "nouveau_projet_oss",
        "Nouveau hors OSS" => "nouveau_hors_oss",
        "Mise à jour" => "mise_a_jour"
      }.fetch(candidate["novelty"])
      error("#{path}: URL du signal #{signal['id']} différente du candidat") unless signal["canonical_url"] == candidate["canonical_url"]
      error("#{path}: classe du signal #{signal['id']} différente du candidat") unless signal["classification"] == expected_classification
      %w[impact_architectural urgence pertinence_stack confiance decision owner].each do |field|
        error("#{path}: #{field} du signal #{signal['id']} différent du candidat") unless signal[field] == candidate[field]
      end
      error("#{path}: échéance du signal #{signal['id']} différente du candidat") unless signal["due_date"].to_s == candidate["due_date"].to_s
      error("#{path}: last_seen du signal #{signal['id']} différent de la date du radar") unless signal["last_seen"].to_s == report_date.iso8601
    end
  end

  rejected_new_identities = Array(data["candidates"]).select do |candidate|
    candidate["selection_status"] != "selected" && candidate["novelty"] != "Mise à jour"
  end.map { |candidate| candidate["identity_key"] }
  signals.each do |signal|
    if rejected_new_identities.include?(signal["identity_key"]) && signal["first_seen"].to_s == report_date.iso8601
      error("#{path}: candidat rejeté ajouté au registre #{signal['id']}")
    end
  end

  coverage_data = contract_yaml(sections_of(text)["sources consultées"].to_s, "watchtower-couverture", path.to_s)
  if coverage_data
    expected_coverage = {
      "algorithm" => data["algorithm"],
      "control_sources" => data.dig("sources", "control"),
      "discovery_sources" => data.dig("sources", "discovery"),
      "qualification_sources" => data.dig("sources", "qualification"),
      "coverage" => data["coverage"]
    }
    error("#{path}: couverture publiée différente du manifest") unless coverage_data == expected_coverage
  end
  exception = data.dig("selection", "oss_exception")
  error("#{path}: exception quota OSS du manifest absente") if exception && !text.include?("Exception quota OSS : #{exception}")
  minimum_exception = data.dig("selection", "minimum_exception")
  if minimum_exception && !text.include?("Exception minimum de sujets : #{minimum_exception}")
    error("#{path}: exception minimum de sujets du manifest absente")
  end
  failure_section = sections_of(text)["sources en échec"].to_s
  Array(data["source_failures"]).each do |failure|
    unless failure_section.include?(failure["source_id"]) && failure_section.include?(failure["period"]) && failure_section.include?(failure["consequence"])
      error("#{path}: échec de source #{failure['source_id']} différent du manifest")
    end
  end
rescue Psych::Exception => e
  error("#{manifest_path.relative_path_from(root)}: YAML invalide (#{e.message})")
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

def validate_report(relative_path, source_data, sources, signals)
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
    previous_usage = previous.lines.any? { |line| line.start_with?("> **Tokens utilisés :**") }
    require_duration = !status.success? && path.basename.to_s == "radar-architecture.md"
    validate_contract(
      text,
      path,
      ROOT,
      require_token_usage: !status.success? || previous_usage,
      require_duration: require_duration
    )
    validate_radar_manifest(path, text, sources, signals) if path.basename.to_s == "radar-architecture.md"
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
signals = validate_signals
validate_local_links

validated_reports = if report
  [report]
else
  Dir.glob(ROOT.join("dist/*/*.md").to_s).sort.select do |path|
    date = Pathname.new(path).parent.basename.to_s
    date.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.parse(date) >= REPORT_RULES_EFFECTIVE_FROM
  end.map do |path|
    Pathname.new(path).relative_path_from(ROOT).to_s
  end
end

validated_reports.each { |path| validate_report(path, source_data, sources, signals) }
validate_monthly_editions(ROOT)
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
