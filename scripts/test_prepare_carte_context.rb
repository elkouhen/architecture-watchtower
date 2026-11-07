# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "prepare_carte_context"

class PrepareCarteContextTest < Minitest::Test
  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def test_projects_only_records_related_to_the_service
    Dir.mktmpdir do |dir|
      write(File.join(dir, "state/context.yaml"), "profile: {role: architecte}\n")
      write(File.join(dir, "state/signals.yaml"), <<~YAML)
        schema_version: 3
        format: tabular-v1
        signal_fields: [id, identity_key, canonical_url, subject, last_seen, status]
        signals:
          - [s1, "oss:elastic:eck", "https://www.elastic.co/eck", "Elastic Cloud on Kubernetes 3.0", 2026-09-01, open]
          - [s2, "other", "https://example.org/x", "Autre sujet", 2026-09-01, open]
      YAML
      write(File.join(dir, "state/learning.yaml"), "products:\n  - {product: Elasticsearch, study_deliverable: dist/2026-08-27/carte-elasticsearch.md}\n  - {product: MCP}\n")
      write(File.join(dir, "docs/catalogue.md"), "| [Elastic Cloud on Kubernetes](https://www.elastic.co/eck) | opérateur |\n| [Autre](https://example.org/x) | outil |\n")
      write(File.join(dir, "docs/contrats-veille.md"), "## Preuves et dates\n\nP.\n\n## Repères des notes\n\nR.\n\n## Exécution économe\n\nE.\n")
      write(File.join(dir, "dist/2026-08-27/carte-elasticsearch.md"), "# x\n")
      write(File.join(dir, "dist/2026-09-01/carte-elastic-cloud-on-kubernetes.md"), "# x\n")

      context = WatchtowerCarteContext.build(root: dir, service: "Elastic Cloud on Kubernetes", date: Date.new(2026, 9, 10))

      assert_equal ["s1"], context["signals"].map { |signal| signal["id"] }
      assert_equal [], context["learning"]
      assert_equal 1, context["catalogue_rows"].length
      assert_equal ["dist/2026-09-01/carte-elastic-cloud-on-kubernetes.md"], context["related_deliverables"]
      assert_equal ["dist/2026-09-01/carte-elastic-cloud-on-kubernetes.md"], context["recent_cartes_within_30_days"]
      assert_equal "dist/2026-09-10/carte-elastic-cloud-on-kubernetes.md", context["target_path"]
      assert_includes context["contract_excerpt"], "## Exécution économe"
      refute_includes context["contract_excerpt"], "## Autre"

      by_url = WatchtowerCarteContext.build(root: dir, service: "ECK", date: Date.new(2026, 9, 10), url: "https://www.elastic.co/eck")
      assert_equal ["s1"], by_url["signals"].map { |signal| signal["id"] }
    end
  end
end
