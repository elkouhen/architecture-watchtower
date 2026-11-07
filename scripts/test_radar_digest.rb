# frozen_string_literal: true

require "date"
require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "radar_digest"

class RadarDigestTest < Minitest::Test
  def write(root, relative, content)
    path = File.join(root, relative)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def setup_cache(dir)
    cache = ".cache/radar/2026-11-07"
    write(dir, "#{cache}/feed/index.md", <<~MD)
      # Delta feed du 2026-10-31

      | Publié | Titre | URL | Fichier |
      |---|---|---|---|
      | 2026-11-05 | GKE node pools now upgrade in place | https://example.org/gke | #{cache}/feed/001-gke.md |
      | 2026-11-04 | Amazon SES available in six new Regions | https://example.org/ses | #{cache}/feed/002-ses.md |
      | 2026-11-03 | November 03, 2026 | https://example.org/digest | #{cache}/feed/003-digest.md |
    MD
    write(dir, "#{cache}/feed/001-gke.md", "# GKE node pools now upgrade in place\n\nURL : https://example.org/gke\nPublié : 2026-11-05\nSource : feed\n\nNodes keep their VM when maxUnavailable > 0.\n")
    write(dir, "#{cache}/feed/002-ses.md", "# Amazon SES available in six new Regions\n\nURL : https://example.org/ses\nPublié : 2026-11-04\nSource : feed\n\nSES is now available in the Paris Region.\n")
    digest_body = "## Cloud Run\n\n### Feature\n\n#{'Ephemeral disk is GA. ' * 20}\n\n## BigQuery\n\n### Breaking\n\n#{'Starting 2027 the connector is deprecated. ' * 20}\n\n## Looker\n\n### Fixed\n\n#{'Minor fix. ' * 40}\n"
    write(dir, "#{cache}/feed/003-digest.md", "# November 03, 2026\n\nURL : https://example.org/digest\nPublié : 2026-11-03\nSource : feed\n\n#{digest_body}")
    write(dir, "#{cache}/page.md", <<~MD)
      # Changelog

      URL : https://example.org/changelog
      Source : page

      ### November, 2026

      Nov 5

      Feature gpt-6 released for the Responses API with new pricing.

      ## GCP-2026-078

      Published: 2026-11-04

      A vulnerability (CVE-2026-98432) in the Linux kernel affects GKE nodes.

      October 2, 2026

      Old entry outside the window.

      Last updated 2026-11-07 UTC.
    MD
    write(dir, "#{cache}/github-trending.md", "# Trending\n\n##\n\nacme /\n\nskills\n\nAgent skills for platforms.\n\nPython\n\n1,200\n\n80\n\nBuilt by\n\n300 stars today\n\n##\n\nother /\n\nrepo\n\nA media player.\n\nRust\n\n10\n\n1\n\nBuilt by\n\n2 stars today\n")
    cache
  end

  def collection(cache)
    [
      { "source_id" => "feed", "status" => "ok", "kind" => "feed", "from" => "2026-10-31", "through" => "2026-11-07", "items_total" => 3,
        "cache_dir" => "#{cache}/feed", "index_path" => "#{cache}/feed/index.md", "item_fields" => %w[published_at title url file excerpt headings], "items" => [] },
      { "source_id" => "page", "status" => "ok", "kind" => "page", "from" => "2026-10-31", "through" => "2026-11-07", "cache_path" => "#{cache}/page.md", "chars" => 300, "headings" => ["# Changelog"] },
      { "source_id" => "dead", "status" => "failed", "kind" => nil, "from" => "2026-10-31", "through" => "2026-11-07", "attempts" => [{ "url" => "https://example.org/dead", "error" => "HTTP 500" }] },
      { "source_id" => "github-trending", "status" => "ok", "kind" => "page", "from" => "2026-10-31", "through" => "2026-11-07", "cache_path" => "#{cache}/github-trending.md", "chars" => 100, "headings" => [] }
    ]
  end

  def test_digest_classifies_items_by_lane_and_stack_and_points_to_cache_lines
    Dir.mktmpdir do |dir|
      cache = setup_cache(dir)
      stats = WatchtowerRadarDigest.build(root: dir, cache_dir: cache, collection: collection(cache), date: Date.new(2026, 11, 7), discovery_ids: ["github-trending"])
      text = File.read(File.join(dir, stats["path"]))

      assert_equal "#{cache}/digest.md", stats["path"]
      assert_includes text, "stack : GKE,node pool · **GKE node pools now upgrade in place** — https://example.org/gke — `#{cache}/feed/001-gke.md`"
      assert_includes text, "Nodes keep their VM when maxUnavailable > 0."
      refute_includes text, "Publié : 2026-11-05"
      assert_includes text, "### Titres seuls (sans mot-clé de stack)\n\n- 2026-11-04 · Amazon SES available in six new Regions — https://example.org/ses"
      assert_includes text, "(digest à sections)"
      assert_includes text, "**Cloud Run** (ligne 1) · voies : releases_features · stack : Cloud Run"
      assert_includes text, "**BigQuery** (ligne 7) · voies : lifecycle_deprecations"
      assert_includes text, "autres sections : Looker"
      assert_includes text, "- 2026-11-05 · ligne 6 · voies : availability_quotas_costs · stack : \n  November, 2026 Nov 5 Feature gpt-6 released"
      assert_includes text, "- 2026-11-04 · ligne 12 · voies : security · stack : GKE\n  GCP-2026-078 Published: 2026-11-04"
      refute_includes text, "Old entry outside the window"
      refute_includes text, "Last updated 2026-11-07"
      assert_includes text, "## dead — échec de collecte (https://example.org/dead : HTTP 500)"
      assert_includes text, "- acme/skills — Agent skills for platforms. (1,200 étoiles, 300 stars today) — https://github.com/acme/skills"
      assert_equal({ "retained" => 3, "titles_only" => 2, "page_blocks" => 2, "discovery_entries" => 2 }, stats.select { |key, _| %w[retained titles_only page_blocks discovery_entries].include?(key) })
    end
  end

  def test_custom_keywords_come_from_the_source_registry
    config = WatchtowerRadarDigest.config({ "digest" => { "stack_keywords" => ["Vault"], "lane_keywords" => { "security" => ["CVE-"] } } })
    assert_equal ["Vault"], config["stack_keywords"]
    assert_equal({ "security" => ["CVE-"] }, config["lane_keywords"])
    assert_equal WatchtowerRadarDigest::DEFAULT_STACK_KEYWORDS, WatchtowerRadarDigest.config({})["stack_keywords"]
  end
end
