# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "index_reports"

class IndexReportsTest < Minitest::Test
  def setup_repo(dir)
    FileUtils.mkdir_p(File.join(dir, "docs"))
    File.write(File.join(dir, "docs/rapports.md"), "# Rapports\n\nIntro.\n\n## 6 novembre 2026\n\n- [Radar architecture](../dist/2026-11-06/radar-architecture.md)\n")
    radars = (1..10).map { |day| "- [Radar du #{day} octobre 2026](dist/2026-10-#{format('%02d', day)}/radar-architecture.md)\n" }.reverse.join
    File.write(File.join(dir, "README.md"), "# Titre\n\n## Livrables\n\n- Radar quotidien : `dist/YYYY-MM-DD/radar-architecture.md`\n- Classement mensuel : `x`\n#{radars}- Carte de service : `y`\n")
  end

  def test_adds_radar_to_both_indexes_idempotently_and_trims_readme
    Dir.mktmpdir do |dir|
      setup_repo(dir)
      2.times { WatchtowerReportIndex.add_radar(root: dir, date: Date.new(2026, 11, 7)) }
      rapports = File.read(File.join(dir, "docs/rapports.md"))
      assert_equal 1, rapports.scan("## 7 novembre 2026").length
      assert rapports.index("## 7 novembre 2026") < rapports.index("## 6 novembre 2026")
      assert_includes rapports, "- [Radar architecture](../dist/2026-11-07/radar-architecture.md)"
      readme = File.read(File.join(dir, "README.md")).lines
      radar_lines = readme.select { |line| line.start_with?("- [Radar du ") }
      assert_equal 10, radar_lines.length
      assert_equal "- [Radar du 7 novembre 2026](dist/2026-11-07/radar-architecture.md)\n", radar_lines.first
      refute_includes readme, "- [Radar du 1 octobre 2026](dist/2026-10-01/radar-architecture.md)\n"
      assert_includes readme, "- Carte de service : `y`\n"
    end
  end
end
