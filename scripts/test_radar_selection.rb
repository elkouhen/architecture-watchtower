# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"
require "yaml"
require_relative "radar_selection"

class RadarSelectionTest < Minitest::Test
  def coverage(complete: true)
    WatchtowerRadarSelection::DOMAINS.product(WatchtowerRadarSelection::LANES).map do |domain, lane|
      {
        "domain" => domain, "lane" => lane, "sources" => ["#{domain.downcase}-source"],
        "scope" => "Périmètre contrôlé.", "checked_at" => "2026-09-10T10:00:00+02:00",
        "from" => "2026-09-09", "through" => "2026-09-10",
        "result" => complete ? "aucun changement retenu" : "échec", "complete" => complete,
        "note" => complete ? "Intervalle parcouru." : "Source inaccessible."
      }
    end
  end

  def candidate(id, overrides = {})
    {
      "id" => id,
      "identity_key" => "product:#{id}",
      "name" => id.capitalize,
      "canonical_url" => "https://example.org/#{id}",
      "nature" => "outil",
      "novelty" => "Nouveau hors OSS",
      "subject" => "Changement #{id}",
      "product_version" => "1.0",
      "environment" => "exposition inconnue",
      "substantive_change" => true,
      "architectural_effect" => true,
      "primary_evidence" => true,
      "open_source" => false,
      "new_project" => false,
      "license" => nil,
      "impact_architectural" => 3,
      "urgence" => 2,
      "pertinence_stack" => 3,
      "confiance" => 4,
      "recency" => "48h",
      "coverage_lanes" => [],
      "signal_level" => "normal",
      "scoring_note" => "Notes justifiées.",
      "fact" => "Fait vérifié.",
      "analysis" => "Conséquence architecturale.",
      "unknowns" => "Exposition locale inconnue.",
      "maturity" => "Maturité documentée.",
      "decision" => "qualify",
      "owner" => "plateforme",
      "due_date" => "2026-09-24",
      "success_criterion" => "Inventaire établi.",
      "evidence" => [{ "source_id" => "source", "url" => "https://example.org/#{id}", "primary" => true, "observed_at" => "2026-09-10", "fact" => "Fait vérifié." }]
    }.merge(overrides)
  end

  def manifest(candidates, complete: true)
    {
      "schema_version" => 1,
      "date" => "2026-09-10",
      "algorithm" => "scan-filter-verify-publish",
      "sources" => {
        "control" => %w[aws-source gcp-source ia-source],
        "discovery" => ["github-trending"],
        "qualification" => []
      },
      "coverage" => coverage(complete: complete),
      "source_failures" => complete ? [] : %w[aws gcp ia].map { |domain|
        { "source_id" => "#{domain}-source", "period" => "2026-09-09/2026-09-10", "consequence" => "Couverture incomplète." }
      },
      "candidate_yield_note" => "Fixture de moins de douze candidats.",
      "candidates" => candidates
    }
  end

  def oss(id, overrides = {})
    candidate(id, {
      "novelty" => "Nouveau projet OSS", "open_source" => true,
      "new_project" => true, "license" => "Apache-2.0"
    }.merge(overrides))
  end

  def test_quiet_cycle_selects_every_eligible_candidate
    data = manifest([candidate("a"), candidate("b"), oss("c")])
    WatchtowerRadarSelection.select!(data)

    assert_equal %w[a b c], data.dig("selection", "selected_ids")
    assert_equal 3, data.dig("selection", "selected_count")
    assert_match(/3 sujet\(s\) éligible\(s\)/, data.dig("selection", "minimum_exception"))
    assert_empty WatchtowerRadarSelection.validate(data, date: Date.new(2026, 9, 10), selected: true)
  end

  def test_critical_candidate_is_first_and_not_evicted_for_quota
    candidates = [candidate("critical", "urgence" => 5)] + (1..5).map { |n| candidate("normal-#{n}") } + [oss("oss-1"), oss("oss-2")]
    data = manifest(candidates)
    WatchtowerRadarSelection.select!(data)

    assert_equal "critical", data.dig("selection", "selected_ids", 0)
    assert data["candidates"].find { |item| item["id"] == "critical" }["mandatory"]
    assert_equal 3, data.dig("selection", "oss_required")
    refute_nil data.dig("selection", "oss_exception")
  end

  def test_quota_replaces_lowest_non_mandatory_candidate
    candidates = (1..5).map { |n| candidate("normal-#{n}", "urgence" => 4) } +
      (1..3).map { |n| oss("oss-#{n}", "urgence" => 1) }
    data = manifest(candidates)
    WatchtowerRadarSelection.select!(data)

    assert_equal 7, data.dig("selection", "selected_count")
    assert_equal 3, data.dig("selection", "oss_selected")
    assert_nil data.dig("selection", "oss_exception")
    assert_nil data.dig("selection", "minimum_exception")
  end

  def test_low_confidence_requires_weak_signal_label
    rejected = candidate("rejected", "confiance" => 2)
    accepted = candidate("accepted", "confiance" => 2, "signal_level" => "signal faible")
    data = manifest([rejected, accepted])
    WatchtowerRadarSelection.select!(data)

    assert_equal ["accepted"], data.dig("selection", "selected_ids")
    assert_match(/confiance inférieure/, rejected["selection_reason"])
  end

  def test_known_identity_must_be_a_substantive_update
    wrong = candidate("wrong", "identity_key" => "known")
    update = candidate("update", "identity_key" => "known-2", "novelty" => "Mise à jour")
    data = manifest([wrong, update])
    WatchtowerRadarSelection.select!(data, identities: { "known" => "SIG-1", "known-2" => "SIG-2" })

    assert_match(/doit être une Mise à jour/, wrong["selection_reason"])
    assert_equal ["update"], data.dig("selection", "selected_ids")
  end

  def test_non_substantive_update_is_rejected
    update = candidate("update", "identity_key" => "known", "novelty" => "Mise à jour", "substantive_change" => false)
    data = manifest([update])
    WatchtowerRadarSelection.select!(data, identities: { "known" => "SIG-1" })

    assert_empty data.dig("selection", "selected_ids")
    assert_equal "changement non substantiel", update["selection_reason"]
  end

  def test_replays_historical_selection_fixtures
    fixture = YAML.safe_load(File.read(File.join(__dir__, "fixtures/radar_selection_cases.yaml")))
    fixture.fetch("cases").each do |scenario|
      candidates = scenario.fetch("candidates").map do |values|
        overrides = values.dup
        id = overrides.delete("id")
        is_oss = overrides.delete("oss")
        is_oss ? oss(id, overrides) : candidate(id, overrides)
      end
      data = manifest(candidates)
      WatchtowerRadarSelection.select!(data)
      assert_equal scenario["expected"], data.dig("selection", "selected_ids"), scenario["name"]
    end
  end

  def test_duplicate_identity_is_rejected_before_selection
    data = manifest([candidate("a", "identity_key" => "same"), candidate("b", "identity_key" => "same")])

    error = assert_raises(WatchtowerRadarSelection::Error) { WatchtowerRadarSelection.select!(data) }
    assert_match(/identity_key candidate dupliquée/, error.message)
  end

  def test_same_release_notes_url_can_carry_distinct_identities
    first = candidate("a", "canonical_url" => "https://example.org/releases")
    second = candidate("b", "canonical_url" => "https://example.org/releases")
    data = manifest([first, second, oss("c")])

    WatchtowerRadarSelection.select!(data)
    assert_equal %w[a b c], data.dig("selection", "selected_ids")
  end

  def test_failed_coverage_is_valid_when_explained
    data = manifest([oss("a")], complete: false)

    assert_empty WatchtowerRadarSelection.validate(data, date: Date.new(2026, 9, 10))
  end

  def test_coverage_results_are_recomputed_from_selected_candidates
    data = manifest([candidate("a", "coverage_lanes" => ["AWS/releases_features"])])
    WatchtowerRadarSelection.select!(data)

    aws_release = data["coverage"].find { |entry| entry["domain"] == "AWS" && entry["lane"] == "releases_features" }
    gcp_release = data["coverage"].find { |entry| entry["domain"] == "GCP" && entry["lane"] == "releases_features" }
    assert_equal "signal retenu", aws_release["result"]
    assert_equal "aucun changement retenu", gcp_release["result"]
  end

  def test_selection_cli_writes_the_locked_manifest
    Dir.mktmpdir("watchtower-selection-cli-") do |dir|
      manifest_path = File.join(dir, "manifest.yaml")
      signals_path = File.join(dir, "signals.yaml")
      File.write(manifest_path, YAML.dump(manifest([oss("a")])))
      File.write(signals_path, YAML.dump({
        "schema_version" => 3, "format" => "tabular-v1",
        "signal_fields" => %w[id identity_key last_seen status], "signals" => []
      }))

      _stdout, stderr, status = Open3.capture3(
        RbConfig.ruby, File.join(__dir__, "select_radar_candidates.rb"),
        "--manifest", manifest_path, "--signals", signals_path
      )
      assert status.success?, stderr
      selected = YAML.safe_load(File.read(manifest_path), permitted_classes: [Date])
      assert_equal ["a"], selected.dig("selection", "selected_ids")
    end
  end
end
