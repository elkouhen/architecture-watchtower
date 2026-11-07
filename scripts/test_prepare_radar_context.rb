# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "tmpdir"
require_relative "prepare_radar_context"

class PrepareRadarContextTest < Minitest::Test
  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def setup_repo(dir)
    write(File.join(dir, "state/context.yaml"), "profile:\n  role: architecte\n")
    write(File.join(dir, "state/learning.yaml"), "products: []\n")
    write(File.join(dir, "state/feedback.yaml"), "feedback:\n  - {date: 2026-09-01, report: radar-architecture, item: A, outcome: useful, correction: Corr, noise: 0}\n")
    write(File.join(dir, "state/signals.yaml"), <<~YAML)
      schema_version: 3
      format: tabular-v1
      signal_fields: [id, canonical_url, subject, last_seen, status, due_date, scoring_note, history]
      signals:
        - [recent, "https://example.org/recent", Recent, 2026-09-08, open, 2026-09-09, "long note", [{date: 2026-09-08, change: x}]]
        - [old, "https://example.org/old", Old, 2026-01-01, closed, 2026-01-02, null, null]
    YAML
    write(File.join(dir, "state/sources.yaml"), <<~YAML)
      schema_version: 3
      format: tabular-v1
      coverage_requirements:
        AWS: {releases_features: [control]}
      feeds:
        control: "https://example.org/feed.xml"
      source_fields: [id, name, type, url, fallback, last_attempt, last_success, last_item_seen, status, notes]
      sources:
        - [control, Control, primary, "https://example.org/page", null, 2026-09-08, 2026-09-08, item, ok, Notes]
        - [github-trending, Trending, discovery, "https://github.com/trending", null, null, null, null, ok, Notes]
        - [unused, Unused, primary, "https://example.org/unused", null, null, null, null, not_checked, Notes]
    YAML
    write(File.join(dir, "docs/catalogue.md"), "# Catalogue\n\n| Élément | Nature |\n|---|---|\n| [Recent](https://example.org/recent) | outil |\n| [Only](https://example.org/only) | outil |\n")
    write(File.join(dir, "dist/2026-09-08/radar-architecture.md"), "## [Recent](https://example.org/recent)\n## [Report](https://example.org/report)\n")
  end

  def test_builds_a_compact_qualification_context
    Dir.mktmpdir("watchtower-context-test-") do |dir|
      setup_repo(dir)
      collection = [{ "source_id" => "control", "status" => "ok", "kind" => "feed", "items" => [] }]
      context = WatchtowerRadarContext.build(root: dir, date: Date.new(2026, 9, 9), collection: collection, reviewed_signals: [{ "id" => "x" }])

      assert_equal %w[id identity_key canonical_url last_seen status], context.dig("recent_signals", "fields")
      assert_equal ["recent", "legacy:recent", "https://example.org/recent", "2026-09-08", "open"], context.dig("recent_signals", "rows", 0)
      assert_equal 1, context.dig("recent_signals", "rows").length
      refute context.key?("due_signals")
      refute context.key?("learning")
      assert_equal [{ "id" => "x" }], context["reviewed_signals"]
      assert_equal collection, context["collection"]
      assert_equal ".cache/radar/2026-09-09", context["cache_dir"]
      assert_equal %w[id url last_success status], context.dig("sources", "fields")
      assert_equal %w[control github-trending], context.dig("sources", "rows").map(&:first).sort
      refute_includes JSON.generate(context), "https://example.org/unused"
      plan = context["collection_plan"].find { |entry| entry["source_ids"] == ["control"] }
      assert_equal ["AWS/releases_features"], plan["lanes"]
      assert_equal "https://example.org/feed.xml", plan["feed_url"]
      assert_equal [["2026-09-08", "Report", "https://example.org/report"]], context.dig("recent_report_subjects", "rows")
      assert_equal [["Only", "https://example.org/only"]], context.dig("catalogue_only_entries", "rows")
      assert_equal %w[correction date item outcome report], context["recent_feedback"][0].keys.sort
      refute_includes JSON.generate(context), "long note"
    end
  end

  def test_writing_context_targets_catalogue_rows
    Dir.mktmpdir("watchtower-context-test-") do |dir|
      setup_repo(dir)
      context = WatchtowerRadarContext.writing(root: dir, date: Date.new(2026, 9, 9), selected_urls: ["https://example.org/recent"])
      assert_equal 4, context.dig("catalogue", "insert_after_line")
      assert_equal "| Élément | Nature |", context.dig("catalogue", "header")
      assert_equal [{ "line" => 5, "text" => "| [Recent](https://example.org/recent) | outil |" }], context.dig("catalogue", "existing_rows_for_selection")
    end
  end
end
