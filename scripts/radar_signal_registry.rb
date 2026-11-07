# frozen_string_literal: true

require "date"
require "yaml"

# Mises à jour déterministes de state/signals.yaml : traitement des échéances et
# synchronisation des signaux depuis un manifest sélectionné. Le modèle ne modifie
# plus ce registre directement.
module WatchtowerRadarSignalRegistry
  class Error < StandardError; end

  AUTO_CLOSE_DECISIONS = %w[monitor].freeze
  CLASSIFICATIONS = {
    "Nouveau projet OSS" => "nouveau_projet_oss",
    "Nouveau hors OSS" => "nouveau_hors_oss",
    "Mise à jour" => "mise_a_jour"
  }.freeze

  module_function

  def load(path)
    data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
    raise Error, "#{path}: format tabular-v1 requis" unless data["format"] == "tabular-v1"

    data
  end

  def dump(data)
    YAML.dump(data, line_width: -1).lines.map { |line| "#{line.rstrip}\n" }.join
  end

  def save(path, data)
    File.write(path, dump(data))
  end

  def records(data)
    fields = data.fetch("signal_fields")
    data.fetch("signals", []).map { |row| fields.zip(row).to_h }
  end

  def write_records(data, records)
    fields = data.fetch("signal_fields")
    data["signals"] = records.map { |record| fields.map { |field| record[field] } }
    data
  end

  def identity(signal)
    value = signal["identity_key"].to_s.strip
    value.empty? ? "legacy:#{signal['id']}" : value
  end

  # Ferme ou diffère les signaux actifs arrivés à échéance. Une décision `monitor`
  # est close (la déduplication sur 90 jours continue de s’appliquer) ; une décision
  # portant une action est différée sans nouvelle échéance.
  def review_due!(data, date:)
    records = records(data)
    reviewed = []
    records.each do |signal|
      next unless %w[new open].include?(signal["status"])

      due = to_date(signal["due_date"])
      next unless due && due <= date

      outcome = AUTO_CLOSE_DECISIONS.include?(signal["decision"]) ? "closed" : "deferred"
      note = if outcome == "closed"
        "Clôture automatique à l’échéance de réexamen du #{due.iso8601} : aucune nouvelle observation consignée ; une Mise à jour substantielle rouvrira le signal."
      else
        "Report automatique à l’échéance du #{due.iso8601} : décision « #{signal['decision']} » non engagée ; reprise sur demande explicite de l'utilisateur."
      end
      signal["status"] = outcome
      signal["last_reviewed"] = date
      signal["review_note"] = note
      signal["history"] = Array(signal["history"]) + [{ "date" => date, "change" => note }]
      reviewed << { "id" => signal["id"], "identity_key" => identity(signal), "subject" => signal["subject"], "status" => outcome }
    end
    write_records(data, records)
    reviewed
  end

  # Crée ou met à jour exactement un signal par candidat sélectionné du manifest.
  def sync_from_manifest!(data, manifest, report_path:, date:, publication: "local_commit")
    records = records(data)
    by_identity = records.each_with_object({}) { |signal, memo| memo[identity(signal)] = signal }
    selected = Array(manifest["candidates"]).select { |candidate| candidate["selection_status"] == "selected" }
    sequence = next_sequence(records, date)
    changes = []
    selected.sort_by { |candidate| candidate["rank"].to_i }.each do |candidate|
      classification = CLASSIFICATIONS.fetch(candidate["novelty"]) { raise Error, "novelty inconnue #{candidate['novelty'].inspect}" }
      signal = by_identity[candidate["identity_key"]]
      if signal
        apply_candidate(signal, candidate, classification, report_path, date, publication)
        signal["status"] = "open"
        signal["history"] = Array(signal["history"]) + [{ "date" => date, "change" => "Radar du #{date.iso8601} : #{candidate['fact']}" }]
        changes << { "id" => signal["id"], "action" => "updated" }
      else
        raise Error, "Mise à jour sans signal existant pour #{candidate['identity_key']}" if candidate["novelty"] == "Mise à jour"

        signal = data.fetch("signal_fields").to_h { |field| [field, nil] }
        signal["id"] = format("SIG-%s-%03d", date.iso8601, sequence)
        sequence += 1
        signal["identity_key"] = candidate["identity_key"]
        signal["first_seen"] = date
        signal["status"] = "new"
        apply_candidate(signal, candidate, classification, report_path, date, publication)
        records << signal
        by_identity[signal["identity_key"]] = signal
        changes << { "id" => signal["id"], "action" => "created" }
      end
    end
    write_records(data, records)
    changes
  end

  def apply_candidate(signal, candidate, classification, report_path, date, publication)
    signal["canonical_url"] = candidate["canonical_url"]
    signal["subject"] = candidate["subject"]
    signal["product_version"] = candidate["product_version"]
    signal["environment"] = candidate["environment"]
    signal["last_seen"] = date
    %w[impact_architectural urgence pertinence_stack confiance decision owner scoring_note].each do |field|
      signal[field] = candidate[field]
    end
    signal["confidence"] = confidence_label(candidate["confiance"])
    signal["due_date"] = to_date(candidate["due_date"]) || raise(Error, "due_date invalide pour #{candidate['id']}")
    signal["classification"] = classification
    signal["deliverables"] = (Array(signal["deliverables"]) + [report_path]).uniq
    signal["publication"] = publication
    signal
  end

  def confidence_label(score)
    case score.to_i
    when 4, 5 then "high"
    when 3 then "medium"
    else "low"
    end
  end

  def next_sequence(records, date)
    prefix = "SIG-#{date.iso8601}-"
    records.map { |signal| signal["id"].to_s }.select { |id| id.start_with?(prefix) }
           .map { |id| id.delete_prefix(prefix).to_i }.max.to_i + 1
  end

  def to_date(value)
    return value if value.is_a?(Date)
    return value.to_date if value.is_a?(Time)
    return nil if value.to_s.strip.empty?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
