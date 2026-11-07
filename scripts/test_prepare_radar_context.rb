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
      collection = [{ "source_id" => "control", "status" => "ok", "kind" => "feed", "from" => "2026-09-08", "through" => "2026-09-09",
                      "items_total" => 1, "items" => [["2026-09-09", "T", "https://example.org/t", "001.md", "extrait", []]],
                      "headings" => ["# a"], "excerpt" => "e", "index_path" => "x/index.md" }]
      context = WatchtowerRadarContext.build(root: dir, date: Date.new(2026, 9, 9), collection: collection,
                                             reviewed_signals: [{ "id" => "x" }], digest: { "path" => "d.md", "bytes" => 10 })

      assert_equal %w[identity_key canonical_url status], context.dig("recent_signals", "fields")
      assert_equal ["legacy:recent", "https://example.org/recent", "open"], context.dig("recent_signals", "rows", 0)
      assert_equal 1, context.dig("recent_signals", "rows").length
      assert_equal [{ "id" => "x" }], context["reviewed_signals"]
      assert_equal ".cache/radar/2026-09-09", context["cache_dir"]
      assert_equal({ "path" => "d.md", "bytes" => 10 }, context["digest"])
      summary = context["collection"].first
      assert_equal %w[source_id status kind from through items_total index_path], summary.keys
      refute summary.key?("items")
      %w[collection_plan sources coverage_requirements control_source_ids].each { |key| refute context.key?(key), key }
      assert_equal [["2026-09-08", "Report", "https://example.org/report"]], context.dig("recent_report_subjects", "rows")
      assert_equal [["Only", "https://example.org/only"]], context.dig("catalogue_only_entries", "rows")
      assert_equal %w[correction date item outcome report], context["recent_feedback"][0].keys.sort
      refute_includes JSON.generate(context), "long note"
      refute_includes JSON.generate(context), "https://example.org/unused"
    end
  end

  def test_selected_sources_cover_control_and_discovery_only
    Dir.mktmpdir("watchtower-context-test-") do |dir|
      setup_repo(dir)
      sources = WatchtowerRadarContext.selected_sources(WatchtowerRadarContext.load_yaml(File.join(dir, "state/sources.yaml")))
      assert_equal %w[control github-trending], sources.map { |source| source["id"] }.sort
    end
  end
end
