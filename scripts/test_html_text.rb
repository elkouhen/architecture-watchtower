# frozen_string_literal: true

require "minitest/autorun"
require_relative "html_text"

class HtmlTextTest < Minitest::Test
  HTML = <<~HTML
    <html><head><style>.x{}</style><script>var a = 1;</script></head>
    <body><nav>Menu</nav>
    <h2>GKE</h2><p>Version <b>1.33</b> &amp; plus.</p>
    <ul><li>Premier point</li><li>Second point</li></ul>
    <table><tr><th>Version</th><th>Fin</th></tr><tr><td>1.30</td><td>2026-12</td></tr></table>
    <!-- commentaire --><h3>Vertex AI</h3><p>Texte.</p></body></html>
  HTML

  def test_converts_headings_lists_and_tables
    text = WatchtowerHtmlText.convert(HTML)
    refute_includes text, "var a"
    refute_includes text, ".x{}"
    assert_includes text, "## GKE"
    assert_includes text, "Version 1.33 & plus."
    assert_includes text, "- Premier point\n- Second point"
    assert_includes text, "| 1.30 | 2026-12"
    assert_equal ["## GKE", "### Vertex AI"], WatchtowerHtmlText.headings(text)
  end

  def test_truncates_and_excerpts
    text = WatchtowerHtmlText.convert("<p>#{'a' * 50}</p>", max_chars: 10)
    assert text.start_with?("aaaaaaaaaa\n\n[tronqué]")
    assert_equal "aaaa…", WatchtowerHtmlText.excerpt("aaaa aaaa", chars: 5)
  end
end
