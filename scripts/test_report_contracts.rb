# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "validate_watchtower"

class ReportContractsTest < Minitest::Test
  def setup
    ERRORS.clear
    WARNINGS.clear
  end

  def card
    CARD_SECTIONS.map { |name| "## #{name}\n\nContenu documenté.\n" }.join("\n") +
      (1..3).map { |n| "Source primaire : [Source #{n}](https://example.org/#{n})\n" }.join
  end

  def monthly_data
    {
      "period" => "2026-08", "mode" => "pondéré",
      "items" => [{ "id" => "outil-a", "rank" => 1, "canonical_url" => "https://example.org/a",
        "classification" => "à qualifier", "urgence" => 3, "score" => 3.0, "trend" => "faible", "trend_evidence" => ["e1"],
        "reason" => "Intégration documentée", "evidence" => ["e1"] }.merge(WEIGHTS.keys.to_h { |key| [key, 3] })],
      "events" => [{ "id" => "e1", "date" => "2026-08-20", "technology" => "outil-a", "origin" => "release", "url" => "https://example.org/releases/1" }],
      "trends" => []
    }
  end

  def monthly(data)
    sections = MONTHLY_SECTIONS.to_h { |name| [name, "Contenu."] }
    sections["Période et méthode"] = "```watchtower-classement\n#{data.to_yaml}```"
    sections["Classement complet"] = "| Rang | Technologie | Pitch rapide — pourquoi c’est intéressant | Tendance | Classe | Lien vers la preuve |\n|---|---|---|---|---|---|\n" + data["items"].map do |item|
      "| #{item['rank']} | [Outil](#{item['canonical_url']}) | Intégration | faible | #{item['classification']} | [preuve](https://example.org/releases/1) |\n"
    end.join
    sections.map { |name, body| "## #{name}\n\n#{body}\n" }.join("\n")
  end

  def check_monthly(data)
    validate_monthly_contract(monthly(data), "test", "2026-08", Date.new(2026, 9, 5), Pathname.new("/tmp/classement-mensuel-2026-08.md"))
  end

  def coverage
    %w[AWS GCP IA].product(%w[releases_features security lifecycle_deprecations availability_quotas_costs]).map do |domain, lane|
      { "domain" => domain, "lane" => lane, "sources" => ["#{domain.downcase}-#{lane}"], "scope" => "Périmètre de test.",
        "checked_at" => "2026-09-05T12:00:00+02:00", "from" => "2026-09-04", "through" => "2026-09-05",
        "result" => "aucun changement retenu", "complete" => true, "note" => "Parcouru." }
    end
  end

  def radar(entries, source_roles = {}, subjects: %w[A B C D E])
    rows = subjects.map.with_index do |name, index|
      kind = index < 2 ? "outil · Nouveau projet OSS" : "service · Nouveau hors OSS"
      "| [#{name}](https://example.org/#{name.downcase}) | #{kind} | Intégration | [fiche](##{name.downcase}) |"
    end.join("\n")
    topics = subjects.map do |name|
      <<~TOPIC
        ## [#{name}](https://example.org/#{name.downcase})

        - **Pitch rapide :** Fait documenté.
        - **Utilité :** Intégration documentée.
      TOPIC
    end.join("\n")
    <<~MD
      ## Vue d’ensemble

      | Outil | Type | Pitch rapide | Lien vers la section |
      |---|---|---|---|
      #{rows}

      #{topics}

      ## Sujets écartés

      Aucun.

      ## Sources consultées

      ```watchtower-couverture
      #{ {
        "algorithm" => "scan-filter-verify-publish",
        "control_sources" => entries.flat_map { |entry| entry["sources"] }.uniq,
        "discovery_sources" => ["github-trending"],
        "qualification_sources" => []
      }.merge(source_roles).merge("coverage" => entries).to_yaml }
      ```

      ## Sources en échec

      Aucun.
    MD
  end

  def test_card_has_its_own_sections
    validate_card(card, "test")
    assert_empty ERRORS
    validate_card(card.sub("## Exploitation", "## Autre"), "test")
    assert ERRORS.any? { |message| message.include?("Exploitation") }
  end

  def test_detailed_token_usage_is_consistent
    valid = "> **Tokens utilisés :** `150` total — entrée `120` (dont cache `80`, hors cache `40`), sortie `30`, " \
      "raisonnement `10` — mesure runtime Codex, durée `00:02:03`. Le cache est facturé nettement moins cher que l’entrée hors cache ; " \
      "`hors cache` et `sortie` approchent le mieux le coût réel.\n"
    validate_token_usage(valid, "test")
    assert_empty ERRORS

    validate_token_usage(valid.sub("`150` total", "`151` total"), "test")
    assert ERRORS.any? { |message| message.include?("total de tokens incohérent") }

    validate_token_usage(valid.sub("hors cache `40`", "hors cache `41`"), "test")
    assert ERRORS.any? { |message| message.include?("entrée hors cache incohérente") }

    validate_token_usage(valid.sub("00:02:03", "00:62:03"), "test")
    assert ERRORS.any? { |message| message.include?("absente ou invalide") }

    without_duration = valid.sub(", durée `00:02:03`", "")
    validate_token_usage(without_duration, "test", require_duration: true)
    assert ERRORS.any? { |message| message.include?("durée de génération requise") }
  end

  def test_card_needs_three_distinct_declared_primary_sources
    validate_card(card.gsub("https://example.org/3", "https://example.org/2"), "test")
    assert ERRORS.any? { |message| message.include?("trois URL") }
  end

  def test_weighted_monthly
    check_monthly(monthly_data)
    assert_empty ERRORS
  end

  def test_unknowns_require_qualitative_mode_and_unknown_score
    data = monthly_data
    data["items"][0]["confiance"] = "inconnu"
    check_monthly(data)
    assert ERRORS.any? { |message| message.include?("score incohérent") }
    assert ERRORS.any? { |message| message.include?("mode attendu") }
    ERRORS.clear
    data["mode"] = "qualitatif"
    data["items"][0]["score"] = "inconnu"
    check_monthly(data)
    assert_empty ERRORS
  end

  def test_future_event_rejected
    data = monthly_data
    data["events"][0]["date"] = "2026-09-01"
    check_monthly(data)
    assert ERRORS.any? { |message| message.include?("hors période") }
  end

  def test_repeated_event_does_not_strengthen_trend
    data = monthly_data
    data["events"] << data["events"][0].merge("id" => "e2")
    data["trends"] << { "id" => "t1", "level" => "forte", "evidence" => %w[e1 e2], "reason" => "Convergence" }
    check_monthly(data)
    assert ERRORS.any? { |message| message.include?("plusieurs fois") }
    assert ERRORS.any? { |message| message.include?("tendance insuffisamment") }
  end

  def test_wrong_ranking_rejected
    data = monthly_data
    data["items"] << data["items"][0].merge("id" => "outil-b", "rank" => 2, "canonical_url" => "https://example.org/b", "impact_architectural" => 5, "score" => 3.5, "evidence" => ["e1"], "trend_evidence" => ["e1"])
    check_monthly(data)
    assert ERRORS.any? { |message| message.include?("ordre ou rangs") }
  end

  def test_duplicate_monthly_editions
    Dir.mktmpdir("watchtower-tests-") do |dir|
      %w[2026-09-01 2026-09-05].each do |day|
        folder = File.join(dir, "dist", day)
        FileUtils.mkdir_p(folder)
        File.write(File.join(folder, "classement-mensuel-2026-08.md"), "archive")
      end
      validate_monthly_editions(Pathname.new(dir))
      assert ERRORS.any? { |message| message.include?("plusieurs éditions") }
    end
  end

  def test_radar_full_coverage
    validate_radar_contract(radar(coverage), "test", Date.new(2026, 9, 5))
    assert_empty ERRORS
  end

  def test_quiet_radar_can_have_no_subject
    validate_radar_contract(radar(coverage, {}, subjects: []), "test", Date.new(2026, 9, 5))
    assert_empty ERRORS
  end

  def test_new_radar_declares_collection_algorithm_and_roles
    current_coverage = coverage.map do |entry|
      entry.merge("checked_at" => "2026-09-08T12:00:00+02:00", "through" => "2026-09-08")
    end
    validate_radar_contract(radar(current_coverage), "test", Date.new(2026, 9, 8))
    assert_empty ERRORS

    validate_radar_contract(radar(current_coverage, "discovery_sources" => %w[a b c]), "test", Date.new(2026, 9, 8))
    assert ERRORS.any? { |message| message.include?("plus de deux sources de découverte") }
  end

  def test_radar_requires_at_least_one_discovery_source
    current_coverage = coverage.map do |entry|
      entry.merge("checked_at" => "2026-09-08T12:00:00+02:00", "through" => "2026-09-08")
    end
    validate_radar_contract(radar(current_coverage, "discovery_sources" => []), "test", Date.new(2026, 9, 8))
    assert ERRORS.any? { |message| message.include?("aucune source de découverte consultée") }
  end

  def test_coverage_sources_must_be_controls
    current_coverage = coverage.map do |entry|
      entry.merge("checked_at" => "2026-09-08T12:00:00+02:00", "through" => "2026-09-08")
    end
    validate_radar_contract(radar(current_coverage, "control_sources" => ["aws-releases_features"]), "test", Date.new(2026, 9, 8))
    assert ERRORS.any? { |message| message.include?("absente de control_sources") }
  end

  def test_radar_missing_lane
    validate_radar_contract(radar(coverage.drop(1)), "test", Date.new(2026, 9, 5))
    assert ERRORS.any? { |message| message.include?("douze voies") }
  end

  def test_explicit_collection_failure_is_allowed
    entries = coverage
    entries[0].merge!("complete" => false, "result" => "échec", "note" => "Intervalle du 4 au 5 septembre inaccessible.")
    validate_radar_contract(radar(entries), "test", Date.new(2026, 9, 5))
    assert ERRORS.any? { |message| message.include?("non déclarée") }
    ERRORS.clear
    validate_radar_contract(radar(entries) + "\nCouverture incomplète\n", "test", Date.new(2026, 9, 5))
    assert_empty ERRORS
  end

  def test_malformed_yaml_is_reported
    validate_radar_contract(radar(coverage).sub("coverage:", "coverage: ["), "test", Date.new(2026, 9, 5))
    assert ERRORS.any? { |message| message.include?("YAML") }
  end

  def test_report_must_match_selected_manifest
    Dir.mktmpdir("watchtower-manifest-test-") do |dir|
      root = Pathname.new(dir)
      report_path = root.join("dist/2026-09-10/radar-architecture.md")
      manifest_path = root.join("state/radar-runs/2026-09-10.yaml")
      FileUtils.mkdir_p(report_path.dirname)
      FileUtils.mkdir_p(manifest_path.dirname)
      current_coverage = coverage.map do |entry|
        entry.merge("checked_at" => "2026-09-10T12:00:00+02:00", "through" => "2026-09-10")
      end
      candidate = {
        "id" => "candidate-a", "identity_key" => "product:a", "name" => "A",
        "canonical_url" => "https://example.org/a", "nature" => "outil", "novelty" => "Nouveau projet OSS",
        "subject" => "Changement A", "product_version" => "1.0", "environment" => "exposition inconnue",
        "substantive_change" => true, "architectural_effect" => true, "primary_evidence" => true,
        "open_source" => true, "new_project" => true, "license" => "MIT",
        "impact_architectural" => 3, "urgence" => 2, "pertinence_stack" => 3, "confiance" => 4,
        "recency" => "48h", "coverage_lanes" => [], "signal_level" => "normal", "scoring_note" => "Notes justifiées.",
        "fact" => "Fait documenté.", "analysis" => "Impact documenté.", "unknowns" => "Exposition inconnue.",
        "maturity" => "Projet maintenu.", "decision" => "qualify", "owner" => "plateforme",
        "due_date" => "2026-09-24", "success_criterion" => "Inventaire établi.",
        "evidence" => [{ "source_id" => "source", "url" => "https://example.org/a", "primary" => true,
          "observed_at" => "2026-09-10", "fact" => "Version vérifiée." }]
      }
      manifest = {
        "schema_version" => 1, "date" => "2026-09-10", "algorithm" => "scan-filter-verify-publish",
        "sources" => { "control" => current_coverage.flat_map { |entry| entry["sources"] }.uniq,
          "discovery" => ["github-trending"], "qualification" => ["source"] },
        "coverage" => current_coverage, "source_failures" => [],
        "candidate_yield_note" => "Fixture de moins de douze candidats.", "candidates" => [candidate]
      }
      WatchtowerRadarSelection.select!(manifest)
      File.write(manifest_path, YAML.dump(manifest))
      report = radar(current_coverage, { "qualification_sources" => ["source"] }, subjects: ["A"])
      report = report.sub("Aucun.", "Exception minimum de sujets : #{manifest.dig('selection', 'minimum_exception')}")
      File.write(report_path, report)
      source_ids = manifest["sources"].values.flatten.uniq
      sources = source_ids.map { |id| { "id" => id, "last_attempt" => "2026-09-10" } }
      signals = [{ "id" => "SIG-2026-09-10-001", "identity_key" => "product:a",
        "canonical_url" => "https://example.org/a", "classification" => "nouveau_projet_oss",
        "impact_architectural" => 3, "urgence" => 2, "pertinence_stack" => 3, "confiance" => 4,
        "decision" => "qualify", "owner" => "plateforme", "due_date" => "2026-09-24",
        "first_seen" => "2026-09-10", "last_seen" => "2026-09-10",
        "deliverables" => ["dist/2026-09-10/radar-architecture.md"] }]

      validate_radar_manifest(report_path, report, sources, signals, root: root)
      assert_empty ERRORS

      validate_radar_manifest(report_path, report.sub("https://example.org/a", "https://example.org/other"), sources, signals, root: root)
      assert ERRORS.any? { |message| message.include?("sélection publiée différente") }
    end
  end
end
