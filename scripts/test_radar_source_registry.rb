# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require "yaml"
require_relative "radar_source_registry"

class RadarSourceRegistryTest < Minitest::Test
  def test_updates_one_compact_row_without_reformatting_the_registry
    Dir.mktmpdir("watchtower-source-test-") do |dir|
      path = File.join(dir, "sources.yaml")
      File.write(path, <<~YAML)
        # commentaire conservé
        schema_version: 3
        format: tabular-v1
        source_fields: [id, name, last_attempt, last_success, last_item_seen, status, notes]
        sources:
          - [a, Source A, null, null, null, not_checked, Initial]
          - [b, Source B, null, null, null, not_checked, Initial]
      YAML

      WatchtowerRadarSourceRegistry.update(path, "a", {
        "last_attempt" => "2026-09-10", "last_success" => "2026-09-10",
        "last_item_seen" => "release-1", "status" => "ok", "notes" => "Collecté."
      })
      text = File.read(path)
      data = YAML.safe_load(text, permitted_classes: [Date])

      assert_includes text, "# commentaire conservé"
      assert_equal "2026-09-10", data["sources"][0][2]
      assert_equal "release-1", data["sources"][0][4]
      assert_equal "b", data["sources"][1][0]
    end
  end
end
