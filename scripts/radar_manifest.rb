# frozen_string_literal: true

require "date"
require "json"
require "pathname"
require "time"
require "yaml"
require_relative "contract_sections"
require_relative "radar_selection"
require_relative "radar_source_registry"

# Manifest d’exécution du radar (schéma 2) : squelette pré-rempli par script,
# briefs de qualification et de rédaction, mise à jour des curseurs de sources.
module WatchtowerRadarManifest
  class Error < StandardError; end

  SCHEMA_VERSION = 2
  ALGORITHM = "scan-filter-verify-publish"
  DISCOVERY_SOURCE_IDS = %w[github-trending trendshift].freeze
  QUALIFICATION_PROMPT_SECTIONS = ["But et périmètre", "Qualification"].freeze
  WRITING_PROMPT_SECTIONS = ["Rédaction"].freeze
  QUALIFICATION_CONTRACT_SECTIONS = ["Repères des notes"].freeze
  WRITING_PROJECTION_FIELDS = %w[id rank name canonical_url nature novelty origin subject product_version environment
                                 signal_level fact scoring_note decision owner due_date coverage_lanes].freeze

  module_function

  def load(path)
    YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: false) || {}
  rescue Psych::Exception => e
    raise Error, "#{path}: YAML invalide (#{e.message})"
  end

  def save(path, data)
    File.write(path, YAML.dump(data, line_width: -1))
  end

  def lane_requirements(sources_data)
    sources_data.fetch("coverage_requirements", {})
  end

  def control_ids(sources_data)
    lane_requirements(sources_data).values.flat_map { |lanes| lanes.values }.flatten.uniq
  end

  def scopes(sources_data)
    value = sources_data["coverage_scopes"]
    value.is_a?(Hash) ? value : {}
  end

  # Squelette : rôles des sources, douze entrées de couverture et échecs de collecte
  # déduits de la collecte ; le modèle ne renseigne que les candidats, le rendement et,
  # si la qualification le révèle, les notes de couverture.
  def skeleton(date:, sources_data:, collection:, checked_at: Time.now)
    by_id = collection.each_with_object({}) { |result, memo| memo[result["source_id"]] = result }
    failures = []
    collection.each do |result|
      if result["status"] != "ok"
        errors = Array(result["attempts"]).map { |attempt| "#{attempt['url']} : #{attempt['error']}" }.join(" ; ")
        failures << { "source_id" => result["source_id"], "period" => "#{result['from']}/#{result['through']}",
                      "consequence" => "Collecte en échec (#{errors}) : période non parcourue ; aucune absence de changement n’est déduite." }
      end
      if result["gap"]
        failures << { "source_id" => result["source_id"], "period" => "#{result['gap']['from']}/#{result['gap']['through']}",
                      "consequence" => "Interruption de plus de trente jours : période antérieure à la fenêtre non parcourue ; aucune absence de changement n’est déduite." }
      end
      if result["truncated_period"]
        failures << { "source_id" => result["source_id"], "period" => "#{result['truncated_period']['from']}/#{result['truncated_period']['through']}",
                      "consequence" => "Flux plafonné à #{result['feed_items']} éléments : période antérieure à l’élément le plus ancien non parcourue ; aucune absence de changement n’est déduite." }
      end
    end
    coverage = lane_requirements(sources_data).flat_map do |domain, lanes|
      lanes.map do |lane, ids|
        ids = Array(ids)
        results = ids.map { |id| by_id[id] }.compact
        froms = results.map { |result| result["from"] }.compact
        incomplete = results.select { |result| result["status"] != "ok" || result["gap"] || result["truncated_period"] }
        missing = ids - results.map { |result| result["source_id"] }
        notes = incomplete.map do |result|
          reasons = []
          reasons << "échec de collecte" if result["status"] != "ok"
          reasons << "lacune #{result['gap']['from']}/#{result['gap']['through']}" if result["gap"]
          reasons << "flux plafonné, période #{result['truncated_period']['from']}/#{result['truncated_period']['through']} non couverte" if result["truncated_period"]
          "#{result['source_id']} : #{reasons.join(', ')}"
        end
        notes += missing.map { |id| "#{id} : non collectée" }
        complete = notes.empty?
        {
          "domain" => domain, "lane" => lane, "sources" => ids,
          "scope" => scopes(sources_data)["#{domain}/#{lane}"] || "Sources #{ids.join(', ')} ; disponibilité fournisseur, pas exposition locale.",
          "checked_at" => checked_at.iso8601, "from" => (froms.min || date.iso8601), "through" => date.iso8601,
          "result" => results.empty? || results.all? { |result| result["status"] != "ok" } ? "échec" : "aucun changement retenu",
          "complete" => complete,
          "note" => complete ? "Delta #{froms.min || date.iso8601}/#{date.iso8601} collecté par script ; lecture ciblée via le digest." : notes.join(" ; ")
        }
      end
    end
    {
      "schema_version" => SCHEMA_VERSION,
      "date" => date.iso8601,
      "algorithm" => ALGORITHM,
      "sources" => {
        "control" => control_ids(sources_data),
        "discovery" => DISCOVERY_SOURCE_IDS.select { |id| by_id[id] && by_id[id]["status"] == "ok" },
        "qualification" => []
      },
      "coverage" => coverage,
      "source_failures" => failures,
      "candidate_yield_note" => nil,
      "candidates" => []
    }
  end

  def qualification_brief(date:, prompt_text:, contract_text:, context:, manifest_path:, digest_path:, cache_dir:)
    intro = prompt_text.split(/^## /, 2).first.to_s.rstrip
    <<~BRIEF
      # Brief de qualification — radar du #{date.iso8601}

      #{intro}

      #{WatchtowerContractSections.extract(prompt_text, QUALIFICATION_PROMPT_SECTIONS)}
      #{WatchtowerContractSections.extract(contract_text, QUALIFICATION_CONTRACT_SECTIONS)}
      ## Fichiers de travail

      - Manifest à compléter (squelette pré-rempli, schéma 2) : `#{manifest_path}` — renseigne `candidates` et `candidate_yield_note` ; ajuste `complete`/`note` d’une voie seulement si ta lecture contredit le squelette ; ajoute à `sources.qualification` tout identifiant de `state/sources.yaml` utilisé pour vérifier un candidat.
      - Digest des deltas (lecture unique) : `#{digest_path}`.
      - Cache local des sources : `#{cache_dir}/` ; n’ouvre que les fichiers et lignes désignés par le digest.
      - Ne modifie ni `state/signals.yaml`, ni `dist/`, ni `docs/` ; ne lance pas la sélection toi-même.

      ## Contexte préparé

      ```json
      #{JSON.generate(context)}
      ```
    BRIEF
  end

  def writing_projection(manifest)
    Array(manifest["candidates"]).select { |candidate| candidate["selection_status"] == "selected" }
                                 .sort_by { |candidate| candidate["rank"].to_i }.map do |candidate|
      projection = candidate.select { |key, _value| WRITING_PROJECTION_FIELDS.include?(key) }
      projection["evidence_urls"] = Array(candidate["evidence"]).map { |proof| proof["url"] if proof.is_a?(Hash) }.compact
      projection
    end
  end

  def writing_brief(date:, prompt_text:, manifest:, manifest_path:)
    selected = writing_projection(manifest)
    intro = prompt_text.split(/^## /, 2).first.to_s.rstrip
    <<~BRIEF
      # Brief de rédaction — radar du #{date.iso8601}

      #{intro}

      #{WatchtowerContractSections.extract(prompt_text, WRITING_PROMPT_SECTIONS)}
      ## Candidats sélectionnés (#{selected.length})

      Ajoute dans `#{manifest_path}`, sous chaque candidat listé ci-dessous (et seulement ceux-là), les champs de prose
      `pitch_court`, `analyse`, `utilite`, `success_criterion` et, au besoin, `reperes` et `pitch_detaille`
      (au plus #{WatchtowerRadarSelection::MAX_DETAILED_PITCHES} candidats). Ne change aucun autre champ. Le rapport est ensuite rendu par script.

      ```json
      #{JSON.generate(selected)}
      ```
    BRIEF
  end

  # Avance les curseurs des sources après publication : un flux collecté avance toujours ;
  # une page n’avance `last_success` que si toutes ses voies sont déclarées complètes.
  def update_sources_registry(path, collection, manifest, date:)
    complete_sources = Array(manifest["coverage"]).select { |entry| entry["complete"] == true && entry["result"] != "échec" }
                                                  .flat_map { |entry| Array(entry["sources"]) }.uniq
    incomplete_sources = Array(manifest["coverage"]).reject { |entry| entry["complete"] == true && entry["result"] != "échec" }
                                                    .flat_map { |entry| Array(entry["sources"]) }.uniq
    collection.each do |result|
      attributes = { "last_attempt" => date.iso8601 }
      case [result["status"], result["kind"]]
      when %w[ok feed]
        attributes.merge!("last_success" => date.iso8601, "status" => "ok", "last_item_seen" => result["latest_item_id"],
                          "notes" => "Collecte structurée du flux le #{date.iso8601} : #{result['items_total']} élément(s) en delta.")
      when %w[ok page]
        if complete_sources.include?(result["source_id"]) && !incomplete_sources.include?(result["source_id"])
          attributes.merge!("last_success" => date.iso8601, "status" => "ok",
                            "notes" => "Page capturée et voies déclarées complètes le #{date.iso8601} (#{result['chars']} caractères).")
        else
          attributes["notes"] = "Page capturée le #{date.iso8601} (#{result['chars']} caractères) ; couverture déclarée incomplète ou page de découverte."
          attributes.merge!("last_success" => date.iso8601, "status" => "ok") if DISCOVERY_SOURCE_IDS.include?(result["source_id"])
        end
      else
        errors = Array(result["attempts"]).map { |attempt| "#{attempt['url']} : #{attempt['error']}" }.join(" ; ")
        attributes.merge!("status" => "failed", "notes" => "Collecte en échec le #{date.iso8601} : #{errors}")
      end
      WatchtowerRadarSourceRegistry.update(path, result["source_id"], attributes)
    end
  end
end
