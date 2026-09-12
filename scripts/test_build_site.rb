#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "build_site"

class BuildSiteTest < Minitest::Test
  def setup
    @temporary_directory = Dir.mktmpdir("watchtower-mkdocs-")
    @destination = Pathname.new(@temporary_directory).join("site")
  end

  def teardown
    FileUtils.remove_entry(@temporary_directory)
  end

  def test_prepares_homepage_reports_and_documentation
    prepare_site_sources(destination: @destination)

    homepage = @destination.join("index.md").read
    assert_includes homepage, "Derniers signaux"
    assert_includes homepage, 'class="watchtower-hero"'
    assert_includes homepage, "dist/2026-09-12/radar-architecture/"
    assert_includes homepage, "docs/catalogue/"
    refute_includes homepage, "Validation locale"
    refute_includes homepage, "state/signals.yaml"
    assert @destination.join("dist", "2026-09-11", "radar-architecture.md").file?
    assert @destination.join("docs", "catalogue.md").file?
    assert @destination.join("docs", "algorithme-radar.html").file?
  end

  def test_staging_does_not_copy_operational_state
    prepare_site_sources(destination: @destination)

    refute @destination.join("state").exist?
    refute @destination.join("scripts").exist?
  end
end
