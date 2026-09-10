# frozen_string_literal: true

require "date"
require "yaml"

module WatchtowerRadarSelection
  class Error < StandardError; end

  DOMAINS = %w[AWS GCP IA].freeze
  LANES = %w[releases_features security lifecycle_deprecations availability_quotas_costs].freeze
  NATURES = %w[outil service pattern standard plateforme modèle bibliothèque].freeze
  NOVELTIES = ["Nouveau projet OSS", "Nouveau hors OSS", "Mise à jour"].freeze
  RECENCY = { "48h" => 0, "7d" => 1, "30d" => 2, "discovery" => 3 }.freeze
  SIGNAL_LEVELS = ["normal", "signal faible"].freeze

  module_function

  def registry_records(data, collection, fields_key)
    rows = data.fetch(collection, [])
    return rows unless data["format"] == "tabular-v1"

    fields = data.fetch(fields_key)
    rows.map { |row| fields.zip(row).to_h }
  end

  def legacy_identity(signal)
    value = signal["identity_key"].to_s.strip
    value.empty? ? "legacy:#{signal['id']}" : value
  end

  def recent_identities(signals_data, date)
    start = date - 90
    registry_records(signals_data, "signals", "signal_fields").each_with_object({}) do |signal, result|
      seen = Date.parse(signal["last_seen"].to_s)
      next unless %w[new open].include?(signal["status"]) || seen >= start

      result[legacy_identity(signal)] = signal["id"]
    rescue Date::Error
      result[legacy_identity(signal)] = signal["id"]
    end
  end

  def validate(data, date: nil, selected: false)
    errors = []
    errors << "schema_version doit valoir 1" unless data["schema_version"] == 1
    manifest_date = parse_date(data["date"], "date", errors)
    errors << "date du manifest inattendue" if date && manifest_date && manifest_date != date
    errors << "algorithm doit valoir scan-filter-verify-publish" unless data["algorithm"] == "scan-filter-verify-publish"

    roles = data["sources"]
    unless roles.is_a?(Hash)
      errors << "sources doit être un objet"
      roles = {}
    end
    %w[control discovery qualification].each do |role|
      values = roles[role]
      errors << "sources.#{role} doit être une liste d’identifiants uniques" unless string_list?(values)
    end
    errors << "au moins une source de contrôle est requise" if Array(roles["control"]).empty?
    discoveries = Array(roles["discovery"])
    errors << "une à deux sources de découverte sont requises" unless discoveries.length.between?(1, 2)

    coverage = data["coverage"]
    if !coverage.is_a?(Array)
      errors << "coverage doit être une liste"
    else
      expected = DOMAINS.product(LANES)
      pairs = coverage.map { |entry| [entry["domain"], entry["lane"]] if entry.is_a?(Hash) }.compact
      errors << "les douze voies de couverture uniques sont requises" unless pairs.length == 12 && pairs.uniq.sort == expected.sort
      coverage.each_with_index { |entry, index| validate_coverage(entry, index, manifest_date, roles, errors) }
    end

    candidates = data["candidates"]
    if !candidates.is_a?(Array)
      errors << "candidates doit être une liste"
      candidates = []
    end
    duplicate_values(candidates, "id").each { |value| errors << "id candidat dupliqué #{value}" }
    duplicate_values(candidates, "identity_key").each { |value| errors << "identity_key candidate dupliquée #{value}" }
    candidates.each_with_index { |candidate, index| validate_candidate(candidate, index, errors) }
    if candidates.length < 12 && data["candidate_yield_note"].to_s.strip.empty?
      errors << "candidate_yield_note requis lorsque moins de douze candidats sont examinés"
    end
    failures = data["source_failures"]
    if !failures.is_a?(Array)
      errors << "source_failures doit être une liste"
    else
      failures.each_with_index do |failure, index|
        valid = failure.is_a?(Hash) && !failure["source_id"].to_s.empty? &&
          !failure["period"].to_s.empty? && !failure["consequence"].to_s.empty?
        errors << "source_failures[#{index}] incomplet" unless valid
      end
      Array(coverage).select { |entry| entry.is_a?(Hash) && (entry["complete"] == false || entry["result"] == "échec") }.each do |entry|
        explained = failures.any? { |failure| failure.is_a?(Hash) && Array(entry["sources"]).include?(failure["source_id"]) }
        errors << "échec #{entry['domain']}/#{entry['lane']} absent de source_failures" unless explained
      end
    end

    if selected
      selection = data["selection"]
      if !selection.is_a?(Hash)
        errors << "selection calculée absente"
      else
        chosen = candidates.select { |candidate| candidate["selection_status"] == "selected" }
        ids = chosen.sort_by { |candidate| candidate["rank"].to_i }.map { |candidate| candidate["id"] }
        errors << "selected_ids incohérents" unless selection["selected_ids"] == ids
        errors << "rangs sélectionnés incohérents" unless chosen.map { |candidate| candidate["rank"] }.sort == (1..chosen.length).to_a
        errors << "quota OSS calculé incohérent" unless selection["oss_required"] == (chosen.length * 0.33).ceil
        errors << "compte OSS calculé incohérent" unless selection["oss_selected"] == chosen.count { |candidate| new_oss?(candidate) }
      end
    end
    errors
  end

  def select!(data, identities: {})
    errors = validate(data)
    raise Error, errors.join("\n") unless errors.empty?

    candidates = data.fetch("candidates")
    candidates.each do |candidate|
      candidate.delete("rank")
      candidate["mandatory"] = mandatory?(candidate)
      candidate["selection_status"] = "rejected"
      candidate["selection_reason"] = rejection_reason(candidate, identities)
    end

    eligible = candidates.select { |candidate| candidate["selection_reason"].nil? }.sort_by { |candidate| sort_key(candidate) }
    mandatory_count = eligible.count { |candidate| candidate["mandatory"] }
    target = if eligible.length <= 7
      eligible.length
    elsif mandatory_count > 10
      mandatory_count
    else
      [[7, mandatory_count].max, 10].min
    end
    chosen = eligible.first(target)

    required = (chosen.length * 0.33).ceil
    missing = required - chosen.count { |candidate| new_oss?(candidate) }
    if missing.positive?
      replacements = (eligible - chosen).select { |candidate| new_oss?(candidate) }
      victims = chosen.reject { |candidate| candidate["mandatory"] || new_oss?(candidate) }.sort_by { |candidate| sort_key(candidate) }.reverse
      [missing, replacements.length, victims.length].min.times do
        chosen.delete(victims.shift)
        chosen << replacements.shift
      end
    end

    chosen.sort_by! { |candidate| sort_key(candidate) }
    chosen.each_with_index do |candidate, index|
      candidate["selection_status"] = "selected"
      candidate["selection_reason"] = candidate["mandatory"] ? "candidat obligatoire" : "rang déterministe"
      candidate["rank"] = index + 1
    end
    (eligible - chosen).each do |candidate|
      candidate["selection_reason"] = "hors capacité après classement déterministe"
    end

    oss_selected = chosen.count { |candidate| new_oss?(candidate) }
    exception = if oss_selected < required
      "#{oss_selected} nouveau(x) projet(s) OSS éligible(s) pour #{required} requis ; aucune alerte obligatoire n’a été évincée."
    end
    data["selection"] = {
      "selected_ids" => chosen.map { |candidate| candidate["id"] },
      "eligible_count" => eligible.length,
      "selected_count" => chosen.length,
      "mandatory_count" => mandatory_count,
      "oss_required" => required,
      "oss_selected" => oss_selected,
      "oss_exception" => exception
    }
    selected_lanes = chosen.flat_map { |candidate| candidate["coverage_lanes"] }.uniq
    data["coverage"].each do |entry|
      next if entry["complete"] == false || entry["result"] == "échec"
      pair = "#{entry['domain']}/#{entry['lane']}"
      entry["result"] = selected_lanes.include?(pair) ? "signal retenu" : "aucun changement retenu"
    end
    data
  end

  def sort_key(candidate)
    relevance = candidate["pertinence_stack"].is_a?(Integer) ? candidate["pertinence_stack"] : 0
    [
      candidate["mandatory"] ? 0 : 1,
      -candidate["urgence"].to_i,
      -candidate["impact_architectural"].to_i,
      -relevance,
      -candidate["confiance"].to_i,
      RECENCY.fetch(candidate["recency"], 99),
      candidate["identity_key"]
    ]
  end

  def mandatory?(candidate)
    candidate["impact_architectural"] == 5 || candidate["urgence"] == 5
  end

  def new_oss?(candidate)
    candidate["novelty"] == "Nouveau projet OSS" && candidate["open_source"] == true && candidate["new_project"] == true
  end

  def rejection_reason(candidate, identities)
    identity = candidate["identity_key"]
    known = identities.key?(identity)
    return "identité récente connue : le candidat doit être une Mise à jour" if known && candidate["novelty"] != "Mise à jour"
    return "identité inconnue : une Mise à jour doit référencer un signal existant" if !known && candidate["novelty"] == "Mise à jour"
    return "changement non substantiel" unless candidate["substantive_change"] == true
    return "impact architectural non démontré" unless candidate["architectural_effect"] == true
    return "preuve primaire absente" unless candidate["primary_evidence"] == true
    return "impact architectural inférieur à 3" unless candidate["impact_architectural"].is_a?(Integer) && candidate["impact_architectural"] >= 3
    return "confiance inférieure à 3 sans classement signal faible" if candidate["confiance"].to_i < 3 && candidate["signal_level"] != "signal faible"
    if candidate["novelty"] == "Nouveau projet OSS"
      return "projet non confirmé comme nouveau et open source" unless new_oss?(candidate)
      return "licence OSS non vérifiée" if candidate["license"].to_s.strip.empty? || candidate["license"] == "inconnue"
    end
    nil
  end

  def validate_candidate(candidate, index, errors)
    label = "candidates[#{index}]"
    unless candidate.is_a?(Hash)
      errors << "#{label} doit être un objet"
      return
    end
    %w[id identity_key name canonical_url nature novelty subject product_version environment recency signal_level scoring_note fact analysis unknowns maturity decision owner due_date success_criterion].each do |field|
      errors << "#{label}.#{field} absent" if candidate[field].to_s.strip.empty?
    end
    errors << "#{label}.canonical_url invalide" unless http_url?(candidate["canonical_url"])
    errors << "#{label}.nature invalide" unless NATURES.include?(candidate["nature"])
    errors << "#{label}.novelty invalide" unless NOVELTIES.include?(candidate["novelty"])
    errors << "#{label}.recency invalide" unless RECENCY.key?(candidate["recency"])
    errors << "#{label}.signal_level invalide" unless SIGNAL_LEVELS.include?(candidate["signal_level"])
    errors << "#{label}.decision invalide" unless %w[monitor qualify test adopt avoid].include?(candidate["decision"])
    parse_date(candidate["due_date"], "#{label}.due_date", errors)
    lanes = candidate["coverage_lanes"]
    valid_lanes = DOMAINS.product(LANES).map { |domain, lane| "#{domain}/#{lane}" }
    unless lanes.is_a?(Array) && lanes.uniq.length == lanes.length && (lanes - valid_lanes).empty?
      errors << "#{label}.coverage_lanes invalide"
    end
    %w[substantive_change architectural_effect primary_evidence open_source new_project].each do |field|
      errors << "#{label}.#{field} doit être booléen" unless [true, false].include?(candidate[field])
    end
    %w[impact_architectural urgence confiance].each do |field|
      errors << "#{label}.#{field} doit être noté de 1 à 5" unless score?(candidate[field])
    end
    relevance = candidate["pertinence_stack"]
    errors << "#{label}.pertinence_stack invalide" unless score?(relevance) || relevance == "inconnu"
    evidence = candidate["evidence"]
    errors << "#{label}.evidence doit être une liste" unless evidence.is_a?(Array)
    if candidate["primary_evidence"] == true
      primary = Array(evidence).any? do |item|
        item.is_a?(Hash) && item["primary"] == true && http_url?(item["url"]) && !item["source_id"].to_s.empty? &&
          !item["fact"].to_s.empty? && parse_date(item["observed_at"], "#{label}.evidence.observed_at", []).is_a?(Date)
      end
      errors << "#{label} ne contient pas de preuve primaire exploitable" unless primary
    end
  end

  def validate_coverage(entry, index, date, roles, errors)
    label = "coverage[#{index}]"
    unless entry.is_a?(Hash)
      errors << "#{label} doit être un objet"
      return
    end
    sources = entry["sources"]
    errors << "#{label}.sources invalide" unless string_list?(sources) && !sources.empty?
    errors << "#{label}.sources absentes des sources de contrôle" if (Array(sources) - Array(roles["control"])).any?
    errors << "#{label}.scope absent" if entry["scope"].to_s.strip.empty?
    errors << "#{label}.result invalide" unless ["signal retenu", "aucun changement retenu", "échec"].include?(entry["result"])
    errors << "#{label}.complete doit être booléen" unless [true, false].include?(entry["complete"])
    from = parse_date(entry["from"], "#{label}.from", errors)
    through = parse_date(entry["through"], "#{label}.through", errors)
    checked = parse_date(entry["checked_at"], "#{label}.checked_at", errors)
    errors << "#{label}.dates incohérentes" if from && through && checked && (from > through || through > checked)
    errors << "#{label}.checked_at doit correspondre à la date du manifest" if date && checked && checked != date
    if entry["complete"] == false || entry["result"] == "échec"
      errors << "#{label}.note doit expliquer la couverture incomplète" if entry["note"].to_s.strip.empty?
    end
  end

  def duplicate_values(records, field)
    records.map { |record| record[field] if record.is_a?(Hash) }.compact.group_by(&:itself).select { |_value, group| group.length > 1 }.keys
  end

  def string_list?(value)
    value.is_a?(Array) && value.all? { |item| item.is_a?(String) && !item.strip.empty? } && value.uniq.length == value.length
  end

  def score?(value)
    value.is_a?(Integer) && value.between?(1, 5)
  end

  def http_url?(value)
    value.is_a?(String) && value.match?(%r{\Ahttps?://[^\s]+\z})
  end

  def parse_date(value, label, errors)
    return value if value.is_a?(Date)
    return Date.parse(value) if value.is_a?(String)

    errors << "#{label} doit être une date"
    nil
  rescue Date::Error
    errors << "#{label} doit être une date"
    nil
  end
end
