#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require_relative "html_text"
require_relative "radar_collection"

# Capture locale d’une page web pour une carte de service : HTML normalisé en texte,
# titres et taille affichés. Le modèle lit ensuite les seules sections utiles
# (`sed -n`, `rg -n`) au lieu de charger la page entière dans son contexte.
ROOT = Pathname.new(__dir__).join("..").expand_path
options = { cache: ".cache/pages", max_chars: WatchtowerRadarCollection::PAGE_MAX_CHARS }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/fetch_page.rb --url URL [--name NOM] [--cache DIR]"
  parser.on("--url URL", "Page à capturer") { |value| options[:url] = value }
  parser.on("--name NOM", "Nom du fichier de cache (défaut : dérivé de l’URL)") { |value| options[:name] = value }
  parser.on("--cache DIR", "Répertoire de cache relatif à la racine (défaut : .cache/pages)") { |value| options[:cache] = value }
  parser.on("--max-chars N", Integer, "Troncature du texte normalisé") { |value| options[:max_chars] = value }
  parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
end.parse!
abort "--url est requis" unless options[:url]

begin
  body = WatchtowerRadarCollection.fetch(options[:url])
  text = WatchtowerHtmlText.convert(body, max_chars: options[:max_chars])
  name = options[:name] || WatchtowerRadarCollection.slug(options[:url].sub(%r{\Ahttps?://}, ""))
  dir = ROOT.join(options[:cache])
  dir.mkpath
  path = dir.join("#{name}.md")
  path.write("# #{options[:url]}\n\nCapturé : #{Time.now.iso8601}\n\n#{text}\n")
  puts JSON.pretty_generate({
    "url" => options[:url], "path" => path.relative_path_from(ROOT).to_s, "chars" => text.length,
    "lines" => text.lines.length, "truncated" => text.end_with?("[tronqué]"),
    "headings" => WatchtowerHtmlText.headings(text, limit: 40)
  })
rescue WatchtowerRadarCollection::Error => e
  warn "ERREUR: #{e.message}"
  exit 1
end
