#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require "yaml"

module WatchtowerRadarContext
  class Error < StandardError; end

  DUE_SIGNAL_FIELDS = %w[
    id canonical_url subject product_version environment first_seen last_seen
    impact_architectural urgence pertinence_stack confiance status decision owner
    due_date classification last_reviewed review_note
  ].freeze
  RECENT_SIGNAL_FIELDS = %w[
    id canonical_url subject product_version first_seen last_seen status decision owner due_date classification
  ].freeze
  SOURCE_FIELDS = %w[
    id name type url fallback last_attempt last_success last_item_seen status notes
  ].freeze
  DISCOVERY_SOURCE_IDS = %w[github-trending trendshift].freeze

  module_function

  def load_yaml(path)
    YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
  rescue StandardError => e
    raise Error, "#{path}: YAML invalide (#{e.message})"
  end

  def records(data, collection, fields_key)
    rows = data.fetch(collection, [])
    return rows unless data["format"] == "tabular-v1"

    fields = data.fetch(fields_key)
    rows.map { |row| fields.zip(row).to_h }
  end

  def iso(value)
    value.respond_to?(:iso8601) ? value.iso8601 : value
  end

  def compact_record(record, fields)
    fields.each_with_object({}) do |field, result|
      value = record[field]
      result[field] = iso(value) unless value.nil? || value == [] || value == ""
    end
  end

  def compact_table(records, fields)
    {
      "format" => "tabular-v1",
      "fields" => fields,
      "rows" => records.map { |record| fields.map { |field| iso(record[field]) } }
    }
  end

  def report_entries(root, from, through)
    root.glob("dist/*/radar-architecture.md").sort.each_with_object([]) do |path, result|
      report_date = Date.iso8601(path.parent.basename.to_s)
      next unless (from..through).cover?(report_date)

      File.foreach(path) do |line|
        match = line.match(/^## \[([^\]]+)\]\((https?:\/\/[^)]+)\)/)
        result << { "date" => report_date.iso8601, "name" => match[1], "canonical_url" => match[2] } if match
      end
    rescue Date::Error
      next
    end
  end

  def catalogue_entries(root)
    path = root.join("docs/catalogue.md")
    return [] unless path.file?

    path.each_line.each_with_object([]) do |line, result|
      match = line.match(/^\| \[([^\]]+)\]\((https?:\/\/[^)]+)\)/)
      result << { "name" => match[1], "canonical_url" => match[2] } if match
    end.uniq { |entry| entry["canonical_url"] }
  end

  def build(root:, date:)
    root = Pathname.new(root).expand_path
    window_start = date - 90
    signals_data = load_yaml(root.join("state/signals.yaml"))
    sources_data = load_yaml(root.join("state/sources.yaml"))
    signals = records(signals_data, "signals", "signal_fields")
    sources = records(sources_data, "sources", "source_fields")

    recent_signals = signals.select do |signal|
      last_seen = signal["last_seen"] && Date.parse(signal["last_seen"].to_s)
      active = %w[new open].include?(signal["status"])
      active || (last_seen && last_seen >= window_start)
    rescue Date::Error
      true
    end

    due_signals = recent_signals.select do |signal|
      due = signal["due_date"] && Date.parse(signal["due_date"].to_s)
      %w[new open].include?(signal["status"]) && due && due <= date
    rescue Date::Error
      false
    end

    requirements = sources_data.fetch("coverage_requirements", {})
    control_ids = requirements.values.flat_map { |lanes| lanes.values }.flatten.uniq
    selected_source_ids = control_ids + DISCOVERY_SOURCE_IDS
    selected_sources = sources.select { |source| selected_source_ids.include?(source["id"]) }

    recent_report_subjects = report_entries(root, window_start, date)
    known_urls = recent_signals.map { |signal| signal["canonical_url"] } +
      recent_report_subjects.map { |entry| entry["canonical_url"] }
    catalogue_only = catalogue_entries(root).reject { |entry| known_urls.include?(entry["canonical_url"]) }
    feedback_data = load_yaml(root.join("state/feedback.yaml"))
    learning_data = load_yaml(root.join("state/learning.yaml"))

    {
      "schema_version" => 1,
      "date" => date.iso8601,
      "deduplication_window" => { "from" => window_start.iso8601, "through" => date.iso8601 },
      "architecture_context" => load_yaml(root.join("state/context.yaml")),
      "learning" => learning_data,
      "due_signals" => due_signals.map { |signal| compact_record(signal, DUE_SIGNAL_FIELDS) },
      "recent_signals" => compact_table(recent_signals, RECENT_SIGNAL_FIELDS),
      "coverage_requirements" => requirements,
      "control_source_ids" => control_ids,
      "sources" => compact_table(selected_sources, SOURCE_FIELDS),
      "discovery_source_ids" => DISCOVERY_SOURCE_IDS,
      "recent_report_subjects" => compact_table(recent_report_subjects, %w[date name canonical_url]),
      "catalogue_only_entries" => compact_table(catalogue_only, %w[name canonical_url]),
      "recent_feedback" => Array(feedback_data["feedback"]).last(5)
    }
  end
end

if $PROGRAM_NAME == __FILE__
  options = { root: Pathname.new(__dir__).join("..").expand_path, date: Date.today }
  parser = OptionParser.new do |option_parser|
    option_parser.banner = "Usage: ruby scripts/prepare_radar_context.rb [options]"
    option_parser.on("--root PATH", "Racine du dépôt") { |value| options[:root] = Pathname.new(value) }
    option_parser.on("--date YYYY-MM-DD", "Date du radar") { |value| options[:date] = Date.iso8601(value) }
    option_parser.on("-h", "--help", "Afficher cette aide") { puts option_parser; exit }
  end

  begin
    parser.parse!
    puts JSON.generate(WatchtowerRadarContext.build(root: options[:root], date: options[:date]))
  rescue OptionParser::ParseError, Date::Error, WatchtowerRadarContext::Error => e
    warn "ERREUR: #{e.message}"
    exit 2
  end
end
