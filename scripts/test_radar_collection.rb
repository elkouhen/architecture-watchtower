# frozen_string_literal: true

require "fileutils"
require "json"
require "minitest/autorun"
require "tmpdir"
require_relative "radar_collection"

class RadarCollectionTest < Minitest::Test
  FEED = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <rss><channel>
      <item><guid>new</guid><title>Nouvelle version</title><link>https://example.org/new</link><pubDate>Thu, 05 Nov 2026 10:00:00 GMT</pubDate><description>&lt;h3&gt;GKE&lt;/h3&gt;&lt;p&gt;Détail utile.&lt;/p&gt;</description></item>
      <item><guid>old</guid><title>Ancienne</title><link>https://example.org/old</link><pubDate>Mon, 01 Sep 2026 10:00:00 GMT</pubDate><description>Vieux</description></item>
    </channel></rss>
  XML
  PAGE = "<html><body><h1>Trending</h1><ul><li>repo/one — outil</li></ul></body></html>"

  def sources
    [
      { "id" => "feed-source", "name" => "Feed", "url" => "https://example.org/page", "fallback" => nil, "last_success" => "2026-11-01", "last_item_seen" => nil },
      { "id" => "page-source", "name" => "Page", "url" => "https://example.org/trending", "fallback" => nil, "last_success" => nil, "last_item_seen" => nil },
      { "id" => "broken", "name" => "Broken", "url" => "https://example.org/broken", "fallback" => "https://example.org/trending", "last_success" => nil, "last_item_seen" => nil },
      { "id" => "dead", "name" => "Dead", "url" => "https://example.org/dead", "fallback" => nil, "last_success" => "2026-10-01", "last_item_seen" => nil }
    ]
  end

  def fetcher(calls)
    lambda do |url|
      calls << url
      case url
      when "https://example.org/feed.xml" then FEED
      when "https://example.org/trending" then PAGE
      else raise WatchtowerRadarCollection::Error, "HTTP 500"
      end
    end
  end

  def test_collects_feeds_pages_and_failures_once_per_url
    Dir.mktmpdir do |dir|
      calls = []
      results = WatchtowerRadarCollection.collect(
        sources, date: Date.new(2026, 11, 7), root: dir, cache_dir: ".cache/radar/2026-11-07",
        feeds: { "feed-source" => "https://example.org/feed.xml" }, fetcher: fetcher(calls)
      )

      assert_equal 1, calls.count("https://example.org/trending")
      feed = results[0]
      assert_equal ["ok", "feed", 2, "new"], feed.values_at("status", "kind", "feed_items", "latest_item_id")
      assert_equal 1, feed["items"].length
      item = feed["item_fields"].zip(feed["items"][0]).to_h
      assert_equal "2026-11-05", item["published_at"]
      assert_equal [], item["headings"]
      assert_equal "GKE Détail utile.", item["excerpt"]
      cache_file = File.join(dir, feed["cache_dir"], item["file"])
      assert File.file?(cache_file)
      assert_includes File.read(cache_file), "### GKE\n\nDétail utile."
      page = results[1]
      assert_equal %w[ok page], page.values_at("status", "kind")
      assert_includes File.read(File.join(dir, page["cache_path"])), "repo/one"
      assert_equal "2026-10-31", page["from"]
      assert_equal 1, feed["items_total"]
      assert_equal 0, feed["items_omitted_from_context"]
      assert_includes File.read(File.join(dir, feed["index_path"])), "| 2026-11-05 | Nouvelle version | https://example.org/new |"
      assert_equal "ok", results[2]["status"]
      assert_equal "https://example.org/trending", results[2]["url"]
      assert_equal 1, results[2]["attempts"].length
      assert_equal "failed", results[3]["status"]
      assert_equal "2026-10-08", results[3]["from"]
      assert_equal({ "from" => "2026-10-01", "through" => "2026-10-07" }, results[3]["gap"])
    end
  end

  def test_updates_registry_cursors
    Dir.mktmpdir do |dir|
      registry = File.join(dir, "sources.yaml")
      File.write(registry, <<~YAML)
        schema_version: 3
        format: tabular-v1
        source_fields: [id, name, type, url, fallback, last_attempt, last_success, last_item_seen, status, notes]
        sources:
          - ["feed-source", "Feed", "primary", "https://example.org/page", null, null, "2026-11-01", null, "ok", "Notes"]
          - ["page-source", "Page", "primary", "https://example.org/trending", null, null, null, null, "not_checked", "Notes"]
          - ["dead", "Dead", "primary", "https://example.org/dead", null, null, "2026-10-01", null, "ok", "Notes"]
      YAML
      results = WatchtowerRadarCollection.collect(
        sources.reject { |source| source["id"] == "broken" }, date: Date.new(2026, 11, 7), root: dir, cache_dir: "cache",
        feeds: { "feed-source" => "https://example.org/feed.xml" }, fetcher: fetcher([])
      )
      WatchtowerRadarCollection.update_registry(registry, results, date: Date.new(2026, 11, 7))
      rows = YAML.safe_load(File.read(registry))["sources"]
      assert_equal ["2026-11-07", "2026-11-07", "new", "ok"], rows[0].values_at(5, 6, 7, 8)
      assert_equal ["2026-11-07", nil, "not_checked"], rows[1].values_at(5, 6, 8)
      assert_equal ["2026-11-07", "2026-10-01", "failed"], rows[2].values_at(5, 6, 8)
    end
  end
end
