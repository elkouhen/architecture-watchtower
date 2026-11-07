# frozen_string_literal: true

require "cgi"

# Normalisation déterministe d’un fragment HTML en texte lisible : titres,
# listes, tableaux et paragraphes conservés, gabarit et scripts retirés.
module WatchtowerHtmlText
  module_function

  def convert(html, max_chars: nil)
    text = html.to_s.dup
    text.gsub!(%r{<(script|style|noscript|svg|template|iframe)\b.*?</\1\s*>}mi, " ")
    text.gsub!(/<!--.*?-->/m, " ")
    text.gsub!(%r{<\s*h([1-6])\b[^>]*>}i) { "\n\n#{'#' * Regexp.last_match(1).to_i} " }
    text.gsub!(%r{</\s*h[1-6]\s*>}i, "\n\n")
    text.gsub!(%r{<\s*li\b[^>]*>}i, "\n- ")
    text.gsub!(%r{<\s*(td|th)\b[^>]*>}i, " | ")
    text.gsub!(%r{<\s*br\b[^>]*/?>}i, "\n")
    text.gsub!(%r{</?\s*(p|div|tr|ul|ol|table|section|article|pre|blockquote|dl|dt|dd|header|footer|nav|main|aside|figure)\b[^>]*>}i, "\n")
    text.gsub!(/<[^>]+>/, " ")
    text = CGI.unescapeHTML(text)
    text.gsub!(/[ \t \r]+/, " ")
    text.gsub!(/ *\n */, "\n")
    text.gsub!(/\n{3,}/, "\n\n")
    text = text.strip
    text = "#{text[0, max_chars]}\n\n[tronqué]" if max_chars && text.length > max_chars
    text
  end

  def headings(text, limit: 30)
    text.each_line.map { |line| line.strip if line.match?(/\A#{'#'}{1,6} \S/) }.compact.first(limit)
  end

  def excerpt(text, chars: 240)
    flat = text.gsub(/^#+ /, "").gsub(/\s+/, " ").strip
    flat.length > chars ? "#{flat[0, chars - 1]}…" : flat
  end
end
