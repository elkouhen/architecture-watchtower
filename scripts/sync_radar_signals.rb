#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require "yaml"
require_relative "radar_signal_registry"

ROOT = Pathname.new(__dir__).join("..").expand_path
options = { signals: ROOT.join("state/signals.yaml"), publication: "local_commit" }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/sync_radar_signals.rb --manifest PATH --report PATH"
  parser.on("--manifest PATH", "Manifest sélectionné") { |value| options[:manifest] = Pathname.new(value) }
  parser.on("--report PATH", "Chemin relatif du radar produit") { |value| options[:report] = value }
  parser.on("--signals PATH", "Registre des signaux") { |value| options[:signals] = Pathname.new(value) }
  parser.on("--publication VALUE", "Statut de publication à inscrire") { |value| options[:publication] = value }
  parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
end.parse!
abort "--manifest et --report sont requis" unless options[:manifest] && options[:report]

begin
  manifest = YAML.safe_load(options[:manifest].expand_path(ROOT).read, permitted_classes: [Date, Time], aliases: false) || {}
  date = Date.parse(manifest.fetch("date").to_s)
  path = options[:signals].expand_path(ROOT)
  data = WatchtowerRadarSignalRegistry.load(path)
  changes = WatchtowerRadarSignalRegistry.sync_from_manifest!(
    data, manifest, report_path: options[:report], date: date, publication: options[:publication]
  )
  WatchtowerRadarSignalRegistry.save(path, data)
  puts JSON.generate({ "date" => date.iso8601, "changes" => changes })
rescue WatchtowerRadarSignalRegistry::Error, Psych::Exception, ArgumentError, KeyError => e
  warn "ERREUR: #{e.message}"
  exit 1
end
