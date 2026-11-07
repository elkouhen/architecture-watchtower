#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require "yaml"

# Projection locale compacte injectée dans le brief de qualification du radar. Les
# fichiers sous state/, dist/ et docs/ restent les sources de vérité ; le contexte
# ne contient que ce qui sert à dédupliquer et à situer les deltas.
module WatchtowerRadarContext
  class Error < StandardError; end

  RECENT_SIGNAL_FIELDS = %w[identity_key canonical_url status].freeze
  DISCOVERY_SOURCE_IDS = %w[github-trending trendshift].freeze
  FEEDBACK_FIELDS = %w[date report item outcome correction].freeze
  RECENT_FEEDBACK_COUNT = 3
  COLLECTION_SUMMARY_FIELDS = %w[source_id status kind from through gap truncated_period items_total cache_dir cache_path index_path attempts].freeze

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

  def compact_table(records, fields)
    {
      "format" => "tabular-v1",
      "fields" => fields,
      "rows" => records.map { |record| fields.map { |field| iso(record[field]) } }
    }
  end

  def identity_key(record)
    value = record["identity_key"].to_s.strip
    value.empty? ? "legacy:#{record['id']}" : value
  end

  def cache_dir(date)
    ".cache/radar/#{date.iso8601}"
  end

  def feeds(sources_data)
    value = sources_data["feeds"]
    value.is_a?(Hash) ? value : {}
  end

  def requirements(sources_data)
    sources_data.fetch("coverage_requirements", {})
  end

  def control_ids(sources_data)
    requirements(sources_data).values.flat_map { |lanes| lanes.values }.flatten.uniq
  end

  def selected_sources(sources_data)
    wanted = control_ids(sources_data) + DISCOVERY_SOURCE_IDS
    records(sources_data, "sources", "source_fields").select { |source| wanted.include?(source["id"]) }
  end

  def report_entries(root, from, through)
    root.glob("dist/*/radar-architecture.md").sort.each_with_object([]) do |path, result|
      report_date = Date.iso8601(path.parent.basename.to_s)
      next unless (from..through).cover?(report_date)

      File.foreach(path) do |line|
        match = line.match(/^## \[([^\]]+)\]\((https?:\/\/[^)]+)\)/)
        result << { "date" => report_date.iso8601, "name" => match[1], "canonical_url" => match[2] } if match
      end
    rescue ArgumentError
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

  def recent_signals(root, date)
    window_start = date - 90
    signals = records(load_yaml(root.join("state/signals.yaml")), "signals", "signal_fields")
    recent = signals.select do |signal|
      last_seen = signal["last_seen"] && Date.parse(signal["last_seen"].to_s)
      %w[new open].include?(signal["status"]) || (last_seen && last_seen >= window_start)
    rescue ArgumentError
      true
    end
    recent.each { |signal| signal["identity_key"] = identity_key(signal) }
  end

  # Résumé de collecte sans les éléments eux-mêmes : le digest les porte.
  def collection_summary(collection)
    Array(collection).map { |result| result.select { |key, _value| COLLECTION_SUMMARY_FIELDS.include?(key) } }
  end

  # Contexte de la phase de qualification.
  def build(root:, date:, collection: nil, reviewed_signals: [], digest: nil)
    root = Pathname.new(root).expand_path
    window_start = date - 90
    recent = recent_signals(root, date)
    known_urls = recent.map { |signal| signal["canonical_url"] }
    recent_report_subjects = report_entries(root, window_start, date).reject { |entry| known_urls.include?(entry["canonical_url"]) }
    known_urls += recent_report_subjects.map { |entry| entry["canonical_url"] }
    catalogue_only = catalogue_entries(root).reject { |entry| known_urls.include?(entry["canonical_url"]) }
    feedback = Array(load_yaml(root.join("state/feedback.yaml"))["feedback"]).last(RECENT_FEEDBACK_COUNT)

    context = {
      "schema_version" => 3,
      "date" => date.iso8601,
      "deduplication_window" => { "from" => window_start.iso8601, "through" => date.iso8601 },
      "cache_dir" => cache_dir(date),
      "architecture_context" => load_yaml(root.join("state/context.yaml")),
      "reviewed_signals" => reviewed_signals,
      "recent_signals" => compact_table(recent, RECENT_SIGNAL_FIELDS),
      "recent_report_subjects" => compact_table(recent_report_subjects, %w[date name canonical_url]),
      "catalogue_only_entries" => compact_table(catalogue_only, %w[name canonical_url]),
      "recent_feedback" => feedback.map { |entry| entry.slice(*FEEDBACK_FIELDS) }
    }
    context["digest"] = digest unless digest.nil?
    context["collection"] = collection_summary(collection) unless collection.nil?
    context
  end
end

if $PROGRAM_NAME == __FILE__
  options = { root: Pathname.new(__dir__).join("..").expand_path, date: Date.today }
  parser = OptionParser.new do |option_parser|
    option_parser.banner = "Usage: ruby scripts/prepare_radar_context.rb [options]"
    option_parser.on("--root PATH", "Racine du dépôt") { |value| options[:root] = Pathname.new(value) }
    option_parser.on("--date YYYY-MM-DD", "Date du radar") { |value| options[:date] = Date.iso8601(value) }
    option_parser.on("--collection PATH", "Résultat JSON de collect_radar_deltas.rb à résumer") { |value| options[:collection] = value }
    option_parser.on("-h", "--help", "Afficher cette aide") { puts option_parser; exit }
  end

  begin
    parser.parse!
    collection = options[:collection] && JSON.parse(File.read(options[:collection]))
    puts JSON.generate(WatchtowerRadarContext.build(root: options[:root], date: options[:date], collection: collection))
  rescue OptionParser::ParseError, ArgumentError, JSON::ParserError, WatchtowerRadarContext::Error => e
    warn "ERREUR: #{e.message}"
    exit 2
  end
end
