# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "prepare_radar_context"

class PrepareRadarContextTest < Minitest::Test
  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def test_builds_a_compact_targeted_context
    Dir.mktmpdir("watchtower-context-test-") do |dir|
      write(File.join(dir, "state/context.yaml"), "profile:\n  role: architecte\n")
      write(File.join(dir, "state/learning.yaml"), "products: []\n")
      write(File.join(dir, "state/feedback.yaml"), "feedback: []\n")
      write(File.join(dir, "state/signals.yaml"), <<~YAML)
        schema_version: 3
        format: tabular-v1
        signal_fields: [id, canonical_url, subject, last_seen, status, due_date]
        signals:
          - [recent, "https://example.org/recent", Recent, 2026-09-08, open, 2026-09-09]
          - [old, "https://example.org/old", Old, 2026-01-01, closed, 2026-01-02]
      YAML
      write(File.join(dir, "state/sources.yaml"), <<~YAML)
        schema_version: 3
        format: tabular-v1
        coverage_requirements:
          AWS: {releases_features: [control]}
        source_fields: [id, name, type, url, fallback, last_attempt, last_success, last_item_seen, status, notes]
        sources:
          - [control, Control, primary, "https://example.org/feed", null, 2026-09-08, 2026-09-08, item, ok, Notes]
          - [unused, Unused, primary, "https://example.org/unused", null, null, null, null, not_checked, Notes]
      YAML
      write(File.join(dir, "docs/catalogue.md"), "| [Recent](https://example.org/recent) | outil |\n")
      write(File.join(dir, "dist/2026-09-08/radar-architecture.md"), "## [Recent](https://example.org/recent)\n")

      context = WatchtowerRadarContext.build(root: dir, date: Date.new(2026, 9, 9))

      assert_equal "tabular-v1", context.dig("recent_signals", "format")
      assert_equal "recent", context.dig("recent_signals", "rows", 0, 0)
      identity_index = context.dig("recent_signals", "fields").index("identity_key")
      assert_equal "legacy:recent", context.dig("recent_signals", "rows", 0, identity_index)
      assert_equal ["recent"], context["due_signals"].map { |signal| signal["id"] }
      assert_equal "control", context.dig("sources", "rows", 0, 0)
      assert_equal "Recent", context.dig("recent_report_subjects", "rows", 0, 1)
      refute_includes JSON.generate(context), "https://example.org/unused"
      assert_equal ["AWS/releases_features"], context.dig("collection_plan", 0, "lanes")
      assert_equal "2026-09-08", context.dig("collection_plan", 0, "from")
    end
  end
end
