# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "radar_signal_registry"

class RadarSignalRegistryTest < Minitest::Test
  FIELDS = %w[id identity_key canonical_url subject product_version environment first_seen last_seen
              impact_architectural urgence pertinence_stack confiance confidence status decision owner due_date
              classification deliverables publication discard_reason legacy_score history scoring_note last_reviewed review_note].freeze

  def signal(id, overrides = {})
    base = FIELDS.to_h { |field| [field, nil] }.merge(
      "id" => id, "identity_key" => "key:#{id}", "canonical_url" => "https://example.org/#{id}", "subject" => "Sujet #{id}",
      "first_seen" => Date.new(2026, 9, 1), "last_seen" => Date.new(2026, 9, 1), "status" => "new", "decision" => "monitor",
      "owner" => "plateforme", "due_date" => Date.new(2026, 9, 15), "deliverables" => ["dist/2026-09-01/radar-architecture.md"]
    )
    base.merge(overrides)
  end

  def data(*signals)
    { "schema_version" => 3, "format" => "tabular-v1", "signal_fields" => FIELDS, "signals" => signals.map { |record| FIELDS.map { |field| record[field] } } }
  end

  def candidate(id, overrides = {})
    {
      "id" => id, "identity_key" => "key:#{id}", "name" => id, "canonical_url" => "https://example.org/#{id}",
      "novelty" => "Nouveau projet OSS", "subject" => "Sujet #{id}", "product_version" => "1.0", "environment" => "exposition inconnue",
      "impact_architectural" => 4, "urgence" => 2, "pertinence_stack" => 3, "confiance" => 4, "decision" => "qualify",
      "owner" => "plateforme", "due_date" => "2026-10-10", "scoring_note" => "Notes justifiées.", "fact" => "Fait vérifié.",
      "selection_status" => "selected", "rank" => 1
    }.merge(overrides)
  end

  def test_review_due_closes_monitoring_and_defers_actions
    registry = data(
      signal("a", "decision" => "monitor"),
      signal("b", "decision" => "qualify", "status" => "open"),
      signal("c", "due_date" => Date.new(2026, 12, 1)),
      signal("d", "status" => "closed", "last_reviewed" => Date.new(2026, 9, 2), "review_note" => "déjà clos")
    )
    reviewed = WatchtowerRadarSignalRegistry.review_due!(registry, date: Date.new(2026, 11, 7))

    assert_equal %w[a b], reviewed.map { |entry| entry["id"] }
    records = WatchtowerRadarSignalRegistry.records(registry)
    assert_equal %w[closed deferred new closed], records.map { |record| record["status"] }
    assert_equal Date.new(2026, 11, 7), records[0]["last_reviewed"]
    assert_match(/Clôture automatique/, records[0]["review_note"])
    assert_match(/qualify/, records[1]["review_note"])
    assert_equal 1, records[1]["history"].length
    assert_nil records[2]["last_reviewed"]
  end

  def test_sync_creates_new_signal_and_updates_existing_identity
    registry = data(signal("old", "status" => "closed", "last_reviewed" => Date.new(2026, 9, 2), "review_note" => "clos"))
    manifest = {
      "candidates" => [
        candidate("new-oss"),
        candidate("old", "novelty" => "Mise à jour", "rank" => 2, "fact" => "Changement substantiel."),
        candidate("rejected", "selection_status" => "rejected", "rank" => nil)
      ]
    }
    changes = WatchtowerRadarSignalRegistry.sync_from_manifest!(
      registry, manifest, report_path: "dist/2026-11-07/radar-architecture.md", date: Date.new(2026, 11, 7)
    )

    assert_equal [{ "id" => "SIG-2026-11-07-001", "action" => "created" }, { "id" => "old", "action" => "updated" }], changes
    records = WatchtowerRadarSignalRegistry.records(registry)
    created = records.find { |record| record["id"] == "SIG-2026-11-07-001" }
    assert_equal "nouveau_projet_oss", created["classification"]
    assert_equal "new", created["status"]
    assert_equal Date.new(2026, 10, 10), created["due_date"]
    assert_equal "high", created["confidence"]
    assert_equal ["dist/2026-11-07/radar-architecture.md"], created["deliverables"]
    updated = records.find { |record| record["id"] == "old" }
    assert_equal "open", updated["status"]
    assert_equal "mise_a_jour", updated["classification"]
    assert_equal ["dist/2026-09-01/radar-architecture.md", "dist/2026-11-07/radar-architecture.md"], updated["deliverables"]
    assert_match(/Changement substantiel/, updated["history"].last["change"])
    assert_equal 2, records.length
  end

  def test_update_without_existing_signal_is_rejected
    manifest = { "candidates" => [candidate("ghost", "novelty" => "Mise à jour")] }
    assert_raises(WatchtowerRadarSignalRegistry::Error) do
      WatchtowerRadarSignalRegistry.sync_from_manifest!(data, manifest, report_path: "dist/x.md", date: Date.new(2026, 11, 7))
    end
  end

  def test_dump_is_stable_without_trailing_spaces
    Dir.mktmpdir do |dir|
      path = File.join(dir, "signals.yaml")
      WatchtowerRadarSignalRegistry.save(path, data(signal("a", "history" => nil)))
      first = File.read(path)
      WatchtowerRadarSignalRegistry.save(path, WatchtowerRadarSignalRegistry.load(path))
      assert_equal first, File.read(path)
      refute_match(/ \n/, first)
    end
  end
end
