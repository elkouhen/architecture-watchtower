# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "prepare_classement_context"

class PrepareClassementContextTest < Minitest::Test
  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def test_builds_the_monthly_corpus_without_full_reports
    Dir.mktmpdir do |dir|
      write(File.join(dir, "state/signals.yaml"), <<~YAML)
        schema_version: 3
        format: tabular-v1
        signal_fields: [id, identity_key, canonical_url, subject, first_seen, last_seen, status]
        signals:
          - [s1, "k1", "https://example.org/a", "A", 2026-09-10, 2026-09-10, new]
          - [s2, "k2", "https://example.org/b", "B", 2026-08-01, 2026-08-01, closed]
      YAML
      write(File.join(dir, "state/learning.yaml"), "products:\n  - {product: A, last_studied: 2026-09-05}\n  - {product: B, last_studied: 2026-08-05}\n")
      write(File.join(dir, "docs/contrats-veille.md"), "## Preuves et dates\n\nP.\n\n## Repères des notes\n\nR.\n\n## Registre du classement mensuel\n\nC.\n\n## Exécution économe\n\nE.\n")
      write(File.join(dir, "dist/2026-09-10/radar-architecture.md"), <<~MD)
        # Radar

        ## Vue d’ensemble

        | Outil | Type | Pitch rapide | Lien vers la section |
        |---|---|---|---|
        | [Tool A](https://example.org/a) | outil · GCP | Pitch A très long | [Tool A](#tool-a) |

        ## [Tool A](https://example.org/a)

        **Pitch rapide :** Fait.
      MD
      write(File.join(dir, "dist/2026-09-05/carte-a.md"), "# CARTE SERVICE — [Service A](https://example.org/a)\n\n## 1. TYPE\n\n## Sources consultées\n\n- [Doc](https://example.org/a/doc)\n")
      write(File.join(dir, "dist/2026-08-30/radar-architecture.md"), "## [Old](https://example.org/old)\n")
      write(File.join(dir, "dist/2026-09-05/classement-mensuel-2026-08.md"), <<~MD)
        # Classement

        ## Classement complet

        | Rang | Technologie | Pitch | Tendance | Classe | Lien |
        |---|---|---|---|---|---|
        | 1 | [Old](https://example.org/old) | pitch | forte | priorité nouveauté | [r](x) |
      MD

      context = WatchtowerClassementContext.build(root: dir, month: "2026-09")

      assert_equal %w[2026-09-05 2026-09-10], context["corpus"].map { |entry| entry["date"] }
      radar = context["corpus"].find { |entry| entry["kind"] == "radar" }
      assert_equal [{ "name" => "Tool A", "canonical_url" => "https://example.org/a", "type" => "outil · GCP", "pitch" => "Pitch A très long" }], radar["subjects"]
      carte = context["corpus"].find { |entry| entry["kind"] == "carte" }
      assert_equal ["Service A", "https://example.org/a"], carte.values_at("title", "canonical_url")
      assert_equal [{ "label" => "Doc", "url" => "https://example.org/a/doc" }], carte["sources"]
      assert_equal ["s1"], context["signals"].map { |signal| signal["id"] }
      assert_equal ["A"], context["learning"].map { |entry| entry["product"] }
      assert_nil context["existing_edition"]
      assert_equal "2026-08", context.dig("previous_ranking", "period")
      assert_equal [{ "rank" => 1, "name" => "Old", "canonical_url" => "https://example.org/old", "trend" => "forte", "class" => "priorité nouveauté" }], context.dig("previous_ranking", "items")
      assert_includes context["contract_excerpt"], "## Registre du classement mensuel"
    end
  end
end
