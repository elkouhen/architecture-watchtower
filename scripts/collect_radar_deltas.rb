#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require_relative "prepare_radar_context"
require_relative "radar_collection"

ROOT = Pathname.new(__dir__).join("..").expand_path
options = { date: Date.today, update_registry: false, sources: [] }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/collect_radar_deltas.rb [--date YYYY-MM-DD] [--source ID ...] [--update-registry]"
  parser.on("--date YYYY-MM-DD", "Date de collecte") { |value| options[:date] = Date.iso8601(value) }
  parser.on("--source ID", "Limiter à une source (répétable)") { |value| options[:sources] << value }
  parser.on("--cache DIR", "Répertoire de cache relatif à la racine") { |value| options[:cache] = value }
  parser.on("--update-registry", "Mettre à jour les curseurs de state/sources.yaml") { options[:update_registry] = true }
  parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
end.parse!

begin
  cache_dir = options[:cache] || WatchtowerRadarContext.cache_dir(options[:date])
  sources_data = WatchtowerRadarContext.load_yaml(ROOT.join("state/sources.yaml"))
  sources = WatchtowerRadarContext.selected_sources(sources_data)
  sources = sources.select { |source| options[:sources].include?(source["id"]) } unless options[:sources].empty?
  results = WatchtowerRadarCollection.collect(
    sources, date: options[:date], root: ROOT, cache_dir: cache_dir, feeds: WatchtowerRadarContext.feeds(sources_data)
  )
  WatchtowerRadarCollection.update_registry(ROOT.join("state/sources.yaml"), results, date: options[:date]) if options[:update_registry]
  puts JSON.generate(results)
rescue WatchtowerRadarContext::Error, WatchtowerRadarCollection::Error, WatchtowerRadarSourceRegistry::Error => e
  warn "ERREUR: #{e.message}"
  exit 1
end
