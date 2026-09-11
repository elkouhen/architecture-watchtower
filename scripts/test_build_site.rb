#!/usr/bin/env ruby
# frozen_string_literal: true

require "minitest/autorun"
require_relative "build_site"

class BuildSiteTest < Minitest::Test
  def test_watchtower_contract_marker_is_not_rendered
    html = markdown_to_html(<<~MARKDOWN)
      # Radar
      <!-- watchtower:2 -->

      Contenu visible.
    MARKDOWN

    refute_includes html, "watchtower:2"
    assert_includes html, "Contenu visible."
  end

  def test_other_html_comments_are_not_silently_removed
    html = markdown_to_html("<!-- commentaire editorial -->\n")

    assert_includes html, "commentaire editorial"
  end

  def test_marker_inside_code_block_remains_visible
    html = markdown_to_html("```html\n<!-- watchtower:2 -->\n```\n")

    assert_includes html, "watchtower:2"
  end

  def test_blockquote_marker_is_rendered_as_html
    html = markdown_to_html("> **Tokens utilisés :** `42`\n")

    assert_includes html, "<blockquote><p><strong>Tokens utilisés :</strong> <code>42</code></p></blockquote>"
    refute_includes html, "&gt;"
  end

  def test_navigation_links_to_algorithm_from_nested_report
    html = page("Rapport", "Contenu", depth: 2)

    assert_includes html, 'href="../../algorithme-radar.html"'
  end
end
