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
      { "domain" => domain, "lane" => lane, "source" => "https://example.org/releases",
        "checked_at" => "2026-09-05T12:00:00+02:00", "from" => "2026-09-04", "through" => "2026-09-05",
        "result" => "aucun changement retenu", "complete" => true, "note" => "Parcouru." }
    end
  end

  def radar(entries)
    <<~MD
      ## Vue d’ensemble

      | Outil | Type | Pitch rapide | Lien vers la section |
      |---|---|---|---|
      | [A](https://example.org/a) | outil · Nouveau projet OSS | Intégration | [fiche](#a) |

      ## [A](https://example.org/a)

      - **Pitch rapide :** Fait documenté.
      - **Utilité :** Intégration documentée.
      - **Outils similaires :** pas d’équivalent direct.

      ## Sujets écartés

      Aucun.

      ## Sources consultées

      ```watchtower-couverture
      #{ { "coverage" => entries }.to_yaml }
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
end
