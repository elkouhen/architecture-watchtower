#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require_relative "radar_signal_registry"

ROOT = Pathname.new(__dir__).join("..").expand_path
options = { date: Date.today, signals: ROOT.join("state/signals.yaml"), apply: true }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/review_due_signals.rb [--date YYYY-MM-DD] [--dry-run]"
  parser.on("--date YYYY-MM-DD", "Date de revue") { |value| options[:date] = Date.iso8601(value) }
  parser.on("--signals PATH", "Registre des signaux") { |value| options[:signals] = Pathname.new(value) }
  parser.on("--dry-run", "Afficher les signaux concernés sans écrire") { options[:apply] = false }
  parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
end.parse!

begin
  path = options[:signals].expand_path(ROOT)
  data = WatchtowerRadarSignalRegistry.load(path)
  reviewed = WatchtowerRadarSignalRegistry.review_due!(data, date: options[:date])
  WatchtowerRadarSignalRegistry.save(path, data) if options[:apply] && !reviewed.empty?
  puts JSON.generate({ "date" => options[:date].iso8601, "applied" => options[:apply], "reviewed" => reviewed })
rescue WatchtowerRadarSignalRegistry::Error, Psych::Exception, ArgumentError => e
  warn "ERREUR: #{e.message}"
  exit 1
end
