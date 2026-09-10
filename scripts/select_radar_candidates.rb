#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "pathname"
require "yaml"
require_relative "radar_selection"

ROOT = Pathname.new(__dir__).join("..").expand_path
options = { signals: ROOT.join("state/signals.yaml") }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/select_radar_candidates.rb --manifest PATH"
  parser.on("--manifest PATH", "Manifest de qualification") { |value| options[:manifest] = Pathname.new(value) }
  parser.on("--signals PATH", "Registre des signaux") { |value| options[:signals] = Pathname.new(value) }
  parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
end.parse!

abort "--manifest est requis" unless options[:manifest]
manifest = options[:manifest].expand_path(ROOT)
signals = options[:signals].expand_path(ROOT)
abort "Manifest absent: #{manifest}" unless manifest.file?
abort "Registre absent: #{signals}" unless signals.file?

begin
  data = YAML.safe_load(manifest.read, permitted_classes: [Date, Time], aliases: false) || {}
  signal_data = YAML.safe_load(signals.read, permitted_classes: [Date, Time], aliases: true) || {}
  date = Date.parse(data.fetch("date").to_s)
  identities = WatchtowerRadarSelection.recent_identities(signal_data, date)
  WatchtowerRadarSelection.select!(data, identities: identities)
  errors = WatchtowerRadarSelection.validate(data, date: date, selected: true)
  raise WatchtowerRadarSelection::Error, errors.join("\n") unless errors.empty?
  manifest.write(YAML.dump(data))
  puts "Sélection radar calculée: #{data.dig('selection', 'selected_count')} sujet(s), " \
    "#{data.dig('selection', 'oss_selected')}/#{data.dig('selection', 'oss_required')} nouveau(x) projet(s) OSS."
rescue KeyError, Date::Error, Psych::Exception, WatchtowerRadarSelection::Error => e
  warn "ERREUR: #{e.message}"
  exit 1
end
