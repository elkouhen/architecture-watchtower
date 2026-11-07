#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require "yaml"
require_relative "contract_sections"
require_relative "prepare_radar_context"

# Contexte local ciblé pour une carte de service : seuls les enregistrements liés
# au service demandé sont projetés, afin de ne jamais relire les registres entiers.
module WatchtowerCarteContext
  CONTRACT_SECTIONS = ["Preuves et dates", "Repères des notes", "Exécution économe"].freeze
  SIGNAL_FIELDS = %w[id identity_key canonical_url subject product_version environment first_seen last_seen
                     impact_architectural urgence pertinence_stack confiance status decision owner due_date
                     classification deliverables scoring_note review_note].freeze
  DEDUPLICATION_DAYS = 30

  module_function

  def normalize(value)
    value.to_s.unicode_normalize(:nfkd).encode("ASCII", replace: "").downcase
  end

  def slug(value)
    normalize(value).gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
  end

  def matcher(service, url)
    needle = normalize(service)
    tokens = needle.scan(/[a-z0-9]{3,}/).uniq
    url_key = url.to_s.sub(%r{\Ahttps?://}, "").sub(%r{/\z}, "")
    lambda do |*values|
      haystack = normalize(values.map(&:to_s).join(" "))
      next true if !url_key.empty? && haystack.include?(normalize(url_key))
      next true if haystack.include?(needle)

      !tokens.empty? && tokens.all? { |token| haystack.include?(token) }
    end
  end

  def build(root:, service:, date:, url: nil)
    root = Pathname.new(root).expand_path
    match = matcher(service, url)
    signals = WatchtowerRadarContext.records(WatchtowerRadarContext.load_yaml(root.join("state/signals.yaml")), "signals", "signal_fields")
    matching_signals = signals.select { |signal| match.call(signal["subject"], signal["canonical_url"], signal["identity_key"]) }
    learning = Array(WatchtowerRadarContext.load_yaml(root.join("state/learning.yaml"))["products"])
    matching_learning = learning.select { |entry| match.call(entry["product"], entry["study_deliverable"]) }
    catalogue = root.join("docs/catalogue.md")
    catalogue_rows = catalogue.file? ? catalogue.each_line.map(&:rstrip).select { |line| line.start_with?("| [") && match.call(line) } : []
    service_slug = slug(service)
    deliverables = root.glob("dist/*/*.md").sort.map { |path| path.relative_path_from(root).to_s }
                       .select { |path| match.call(path) || (!service_slug.empty? && path.include?(service_slug)) }
    recent_cartes = deliverables.select do |path|
      path.include?("/carte-") && Date.iso8601(path.split("/")[1]) >= date - DEDUPLICATION_DAYS
    rescue ArgumentError
      false
    end
    {
      "schema_version" => 1,
      "date" => date.iso8601,
      "service" => service,
      "service_slug" => service_slug,
      "canonical_url" => url,
      "target_path" => "dist/#{date.iso8601}/carte-#{service_slug}.md",
      "recent_cartes_within_30_days" => recent_cartes,
      "architecture_context" => WatchtowerRadarContext.load_yaml(root.join("state/context.yaml")),
      "signals" => matching_signals.map { |signal| SIGNAL_FIELDS.to_h { |field| [field, WatchtowerRadarContext.iso(signal[field])] } },
      "learning" => matching_learning,
      "catalogue_rows" => catalogue_rows,
      "related_deliverables" => deliverables,
      "contract_excerpt" => WatchtowerContractSections.extract(root.join("docs/contrats-veille.md").read, CONTRACT_SECTIONS)
    }
  end
end

if $PROGRAM_NAME == __FILE__
  options = { root: Pathname.new(__dir__).join("..").expand_path, date: Date.today }
  OptionParser.new do |parser|
    parser.banner = "Usage: ruby scripts/prepare_carte_context.rb --service NOM [--url URL] [--date YYYY-MM-DD]"
    parser.on("--service NOM", "Nom du service") { |value| options[:service] = value }
    parser.on("--url URL", "URL canonique connue") { |value| options[:url] = value }
    parser.on("--date YYYY-MM-DD", "Date de la carte") { |value| options[:date] = Date.iso8601(value) }
    parser.on("--root PATH", "Racine du dépôt") { |value| options[:root] = Pathname.new(value) }
    parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
  end.parse!
  abort "--service est requis" unless options[:service]
  begin
    puts JSON.generate(WatchtowerCarteContext.build(root: options[:root], service: options[:service], date: options[:date], url: options[:url]))
  rescue WatchtowerRadarContext::Error, WatchtowerContractSections::Error, ArgumentError => e
    warn "ERREUR: #{e.message}"
    exit 2
  end
end
