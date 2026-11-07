# frozen_string_literal: true

require "date"
require "minitest/autorun"
require "tmpdir"
require "yaml"
require_relative "radar_manifest"
require_relative "radar_render"
require_relative "radar_selection"

class RadarRenderTest < Minitest::Test
  def sources_data
    {
      "coverage_requirements" => {
        "AWS" => { "releases_features" => ["aws-feed"], "security" => ["aws-feed"], "lifecycle_deprecations" => ["aws-feed"], "availability_quotas_costs" => ["aws-feed"] },
        "GCP" => { "releases_features" => ["gcp-page"], "security" => ["gcp-page"], "lifecycle_deprecations" => ["gcp-page"], "availability_quotas_costs" => ["gcp-page"] },
        "IA" => { "releases_features" => ["ia-dead"], "security" => ["ia-dead"], "lifecycle_deprecations" => ["ia-dead"], "availability_quotas_costs" => ["ia-dead"] }
      },
      "coverage_scopes" => { "AWS/security" => "Bulletins AWS." }
    }
  end

  def collection
    [
      { "source_id" => "aws-feed", "status" => "ok", "kind" => "feed", "from" => "2026-10-31", "through" => "2026-11-07", "items_total" => 40, "feed_items" => 100,
        "latest_item_id" => "last", "truncated_period" => { "from" => "2026-10-31", "through" => "2026-11-02" } },
      { "source_id" => "gcp-page", "status" => "ok", "kind" => "page", "from" => "2026-10-31", "through" => "2026-11-07", "chars" => 1000 },
      { "source_id" => "ia-dead", "status" => "failed", "from" => "2026-10-01", "through" => "2026-11-07", "attempts" => [{ "url" => "https://example.org/ia", "error" => "HTTP 500" }] },
      { "source_id" => "github-trending", "status" => "ok", "kind" => "page", "from" => "2026-10-31", "through" => "2026-11-07", "chars" => 100 }
    ]
  end

  def candidate(id, overrides = {})
    {
      "id" => id, "identity_key" => "product:#{id}", "name" => "Produit #{id.upcase} — (v2)", "canonical_url" => "https://example.org/#{id}",
      "nature" => "service", "novelty" => "Nouveau hors OSS", "origin" => "AWS", "subject" => "Changement #{id}", "product_version" => "1.0",
      "environment" => "exposition inconnue", "substantive_change" => true, "architectural_effect" => true, "primary_evidence" => true,
      "open_source" => false, "new_project" => false, "license" => nil, "impact_architectural" => 4, "urgence" => 3, "pertinence_stack" => 3,
      "confiance" => 4, "recency" => "7d", "coverage_lanes" => ["AWS/security"], "signal_level" => "normal", "scoring_note" => "Notes.",
      "fact" => "Fait #{id} vérifié.", "decision" => "qualify", "owner" => "plateforme", "due_date" => "2026-11-21",
      "evidence" => [{ "source_id" => "aws-feed", "url" => "https://example.org/#{id}/proof", "primary" => true, "observed_at" => "2026-11-07", "published_at" => "2026-11-05", "effective_at" => "inconnue", "fact" => "Preuve #{id}." }],
      "pitch_court" => "Pitch | court #{id}", "analyse" => "Analyse #{id}.", "utilite" => "Utilité #{id}.", "success_criterion" => "Succès #{id}."
    }.merge(overrides)
  end

  def manifest
    data = WatchtowerRadarManifest.skeleton(date: Date.new(2026, 11, 7), sources_data: sources_data, collection: collection, checked_at: Time.new(2026, 11, 7, 9, 0, 0, "+01:00"))
    data["candidate_yield_note"] = "Rendement de test."
    data["candidates"] = [
      candidate("a", "reperes" => "X ; Y", "pitch_detaille" => "Conséquence transverse."),
      candidate("b", "novelty" => "Nouveau projet OSS", "open_source" => true, "new_project" => true, "license" => "MIT", "origin" => nil, "nature" => "outil"),
      candidate("c", "substantive_change" => false, "rejection_note" => "Rien de neuf.")
    ]
    WatchtowerRadarSelection.select!(data)
    data
  end

  def test_skeleton_prefills_coverage_roles_and_failures
    data = manifest
    assert_equal 2, data["schema_version"]
    assert_equal ["github-trending"], data.dig("sources", "discovery")
    assert_equal %w[aws-feed gcp-page ia-dead], data.dig("sources", "control")
    assert_equal 12, data["coverage"].length
    aws = data["coverage"].find { |entry| entry["domain"] == "AWS" && entry["lane"] == "security" }
    assert_equal "Bulletins AWS.", aws["scope"]
    assert_equal false, aws["complete"]
    assert_match(/flux plafonné, période 2026-10-31\/2026-11-02/, aws["note"])
    gcp = data["coverage"].find { |entry| entry["domain"] == "GCP" && entry["lane"] == "security" }
    assert_equal true, gcp["complete"]
    ia = data["coverage"].find { |entry| entry["domain"] == "IA" && entry["lane"] == "security" }
    assert_equal "échec", ia["result"]
    assert_equal %w[aws-feed ia-dead], data["source_failures"].map { |failure| failure["source_id"] }.sort
    assert_empty WatchtowerRadarSelection.validate(data, date: Date.new(2026, 11, 7), selected: true, prose: true)
  end

  def test_report_is_rendered_from_the_manifest
    text = WatchtowerRadarRender.report(manifest, date: Date.new(2026, 11, 7))

    assert text.start_with?("# Radar architecture — 7 novembre 2026\n<!-- watchtower:2 -->\n> **Tokens utilisés :** `non disponible` — compteur runtime non exposé.\n")
    assert_includes text, "Couverture incomplète : AWS/releases_features, AWS/security, AWS/lifecycle_deprecations, AWS/availability_quotas_costs — aws-feed : flux plafonné"
    assert_includes text, "| [Produit A — (v2)](https://example.org/a) | service · AWS | Pitch / court a | [Fiche](#produit-a--v2) |"
    assert_includes text, "| [Produit B — (v2)](https://example.org/b) | outil · Nouveau projet OSS |"
    assert_includes text, "## [Produit A — (v2)](https://example.org/a)\n\n- **Pitch rapide :** **Fait :** Fait a vérifié. **Analyse :** Analyse a.\n"
    assert_includes text, "- **Utilité :** Utilité a. Niveau : normal ; exposition locale : exposition inconnue. **Décision :** qualification par `plateforme`, réexamen le 21/11/2026 ; succès = Succès a.\n- **Repères de comparaison :** X ; Y\n\n### Pitch détaillé\n\nConséquence transverse.\n"
    refute_includes text, "### Pitch détaillé\n\n\n## [Produit B"
    assert_includes text, "## Sujets écartés\n\n- [Produit C — (v2)](https://example.org/c) — changement non substantiel : Rien de neuf.\n- Exception minimum de sujets : 2 sujet(s) éligible(s) après les trois filtres ; Rendement de test.\n- Rendement : Rendement de test.\n"
    assert_includes text, "- `aws-feed` — contrôle — [Produit A — (v2)](https://example.org/a/proof) — 1.0 ; publié le 2026-11-05 ; effet inconnue ; consulté le 2026-11-07 ; Preuve a.\n"
    assert_includes text, "- `gcp-page`, `ia-dead` — contrôle — deltas lus dans le cache local le 2026-11-07"
    assert_includes text, "```watchtower-couverture\nalgorithm: scan-filter-verify-publish\n"
    assert_includes text, "## Sources en échec\n\n- `aws-feed` — `2026-10-31/2026-11-02` — Flux plafonné à 100 éléments"
    assert_includes text, "- `ia-dead` — `2026-10-01/2026-11-07` — Collecte en échec (https://example.org/ia : HTTP 500)"
    assert_equal 2, text.scan(/^## \[/).length
  end

  def test_catalogue_rows_are_inserted_or_updated_in_place
    Dir.mktmpdir do |dir|
      path = File.join(dir, "catalogue.md")
      File.write(path, "# Catalogue\n\n| Élément | Nature | Niveau | Revue | Tendance |\n|---|---|---|---|---|\n| [Ancien](https://example.org/b) | nature humaine | veille | [01/10](../dist/2026-10-01/radar-architecture.md) | x |\n")
      WatchtowerRadarRender.catalogue_rows!(path, manifest, date: Date.new(2026, 11, 7))
      lines = File.read(path).lines

      assert_equal "| [Produit A — (v2)](https://example.org/a) | service · AWS | à qualifier | [07/11](../dist/2026-11-07/radar-architecture.md#produit-a--v2) | normal · 07/11 |\n", lines[4]
      assert_equal "| [Produit B — (v2)](https://example.org/b) | nature humaine | à qualifier | [07/11](../dist/2026-11-07/radar-architecture.md#produit-b--v2) | normal · 07/11 |\n", lines[5]
      assert_equal 6, lines.length
    end
  end

  def test_writing_brief_lists_selected_candidates_only
    data = manifest
    brief = WatchtowerRadarManifest.writing_brief(date: Date.new(2026, 11, 7), prompt_text: "# P\n\nIntro.\n\n## Rédaction\n\nRègles.\n", manifest: data, manifest_path: "m.yaml")
    assert_includes brief, "## Rédaction\n\nRègles."
    assert_includes brief, "Candidats sélectionnés (2)"
    assert_includes brief, "\"evidence_urls\":[\"https://example.org/a/proof\"]"
    refute_includes brief, "product:c"
    refute_includes brief, "Analyse a."
  end

  def test_sources_registry_cursors_advance_after_publication
    Dir.mktmpdir do |dir|
      registry = File.join(dir, "sources.yaml")
      File.write(registry, <<~YAML)
        schema_version: 3
        format: tabular-v1
        source_fields: [id, name, type, url, fallback, last_attempt, last_success, last_item_seen, status, notes]
        sources:
          - ["aws-feed", "Feed", "primary", "https://example.org/feed", null, null, "2026-10-31", null, "ok", "Notes"]
          - ["gcp-page", "Page", "primary", "https://example.org/page", null, null, null, null, "not_checked", "Notes"]
          - ["ia-dead", "Dead", "primary", "https://example.org/ia", null, null, "2026-10-01", null, "ok", "Notes"]
          - ["github-trending", "Trending", "discovery", "https://github.com/trending", null, null, null, null, "not_checked", "Notes"]
      YAML
      WatchtowerRadarManifest.update_sources_registry(registry, collection, manifest, date: Date.new(2026, 11, 7))
      data = YAML.safe_load(File.read(registry))
      rows = data["sources"].map { |row| data["source_fields"].zip(row).to_h }
      by_id = rows.each_with_object({}) { |row, memo| memo[row["id"]] = row }

      assert_equal ["2026-11-07", "2026-11-07", "last", "ok"], by_id["aws-feed"].values_at("last_attempt", "last_success", "last_item_seen", "status")
      assert_equal ["2026-11-07", "2026-11-07", "ok"], by_id["gcp-page"].values_at("last_attempt", "last_success", "status")
      assert_equal ["2026-11-07", "2026-10-01", "failed"], by_id["ia-dead"].values_at("last_attempt", "last_success", "status")
      assert_equal ["2026-11-07", "2026-11-07", "ok"], by_id["github-trending"].values_at("last_attempt", "last_success", "status")
    end
  end
end
