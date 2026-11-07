#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require "yaml"

# Projection locale compacte injectée dans les tours orchestrés du radar. Les
# fichiers sous state/, dist/ et docs/ restent les sources de vérité.
module WatchtowerRadarContext
  class Error < StandardError; end

  RECENT_SIGNAL_FIELDS = %w[id identity_key canonical_url last_seen status].freeze
  SOURCE_FIELDS = %w[id url last_success status].freeze
  DISCOVERY_SOURCE_IDS = %w[github-trending trendshift].freeze
  FEEDBACK_FIELDS = %w[date report item outcome correction].freeze
  RECENT_FEEDBACK_COUNT = 3

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

  def collection_plan(sources, requirements, date, feeds)
    lanes_by_source = Hash.new { |hash, key| hash[key] = [] }
    requirements.each do |domain, lanes|
      lanes.each do |lane, ids|
        Array(ids).each { |id| lanes_by_source[id] << "#{domain}/#{lane}" }
      end
    end

    sources.group_by { |source| source["url"] }.values.map do |same_url|
      ids = same_url.map { |source| source["id"] }
      roles = []
      roles << "control" if ids.any? { |id| lanes_by_source.key?(id) }
      roles << "discovery" if (ids & DISCOVERY_SOURCE_IDS).any?
      entry = {
        "url" => same_url.first["url"],
        "source_ids" => ids,
        "roles" => roles,
        "lanes" => ids.flat_map { |id| lanes_by_source[id] }.uniq.sort,
        "from" => same_url.map { |source| iso(source["last_success"]) }.compact.min,
        "through" => date.iso8601,
        "fallbacks" => same_url.map { |source| source["fallback"] }.compact.uniq
      }
      feed_urls = ids.map { |id| feeds[id] }.compact.uniq
      entry["feed_url"] = feed_urls.first unless feed_urls.empty?
      entry
    end.sort_by { |entry| entry["url"].to_s }
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

  # Contexte de la phase de qualification.
  def build(root:, date:, collection: nil, reviewed_signals: [])
    root = Pathname.new(root).expand_path
    window_start = date - 90
    sources_data = load_yaml(root.join("state/sources.yaml"))
    requirements = requirements(sources_data)
    feeds = feeds(sources_data)
    selected = selected_sources(sources_data)
    recent = recent_signals(root, date)
    known_urls = recent.map { |signal| signal["canonical_url"] }
    recent_report_subjects = report_entries(root, window_start, date).reject { |entry| known_urls.include?(entry["canonical_url"]) }
    known_urls += recent_report_subjects.map { |entry| entry["canonical_url"] }
    catalogue_only = catalogue_entries(root).reject { |entry| known_urls.include?(entry["canonical_url"]) }
    feedback = Array(load_yaml(root.join("state/feedback.yaml"))["feedback"]).last(RECENT_FEEDBACK_COUNT)

    context = {
      "schema_version" => 2,
      "date" => date.iso8601,
      "deduplication_window" => { "from" => window_start.iso8601, "through" => date.iso8601 },
      "cache_dir" => cache_dir(date),
      "architecture_context" => load_yaml(root.join("state/context.yaml")),
      "reviewed_signals" => reviewed_signals,
      "recent_signals" => compact_table(recent, RECENT_SIGNAL_FIELDS),
      "coverage_requirements" => requirements,
      "control_source_ids" => control_ids(sources_data),
      "discovery_source_ids" => DISCOVERY_SOURCE_IDS,
      "sources" => compact_table(selected, SOURCE_FIELDS),
      "collection_plan" => collection_plan(selected, requirements, date, feeds),
      "recent_report_subjects" => compact_table(recent_report_subjects, %w[date name canonical_url]),
      "catalogue_only_entries" => compact_table(catalogue_only, %w[name canonical_url]),
      "recent_feedback" => feedback.map { |entry| entry.slice(*FEEDBACK_FIELDS) }
    }
    context["collection"] = collection unless collection.nil?
    context
  end

  # Contexte de la phase de rédaction : uniquement ce qu’il faut pour écrire le
  # rapport et insérer les lignes du catalogue sans relire les registres.
  def writing(root:, date:, selected_urls: [])
    root = Pathname.new(root).expand_path
    catalogue = root.join("docs/catalogue.md")
    lines = catalogue.file? ? catalogue.read.lines : []
    separator = lines.index { |line| line.match?(/\A\|\s*-{3,}/) }
    existing = lines.each_with_index.map do |line, index|
      url = line[/^\| \[[^\]]+\]\((https?:\/\/[^)]+)\)/, 1]
      { "line" => index + 1, "text" => line.rstrip } if url && selected_urls.include?(url)
    end.compact
    {
      "schema_version" => 2,
      "date" => date.iso8601,
      "catalogue" => {
        "path" => "docs/catalogue.md",
        "header" => separator ? lines[separator - 1].rstrip : nil,
        "insert_after_line" => separator ? separator + 1 : nil,
        "existing_rows_for_selection" => existing
      }
    }
  end
end

if $PROGRAM_NAME == __FILE__
  options = { root: Pathname.new(__dir__).join("..").expand_path, date: Date.today }
  parser = OptionParser.new do |option_parser|
    option_parser.banner = "Usage: ruby scripts/prepare_radar_context.rb [options]"
    option_parser.on("--root PATH", "Racine du dépôt") { |value| options[:root] = Pathname.new(value) }
    option_parser.on("--date YYYY-MM-DD", "Date du radar") { |value| options[:date] = Date.iso8601(value) }
    option_parser.on("--collection PATH", "Résultat JSON de collect_radar_deltas.rb à inclure") { |value| options[:collection] = value }
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
