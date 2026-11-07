#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "optparse"
require "pathname"
require "yaml"
require_relative "contract_sections"
require_relative "prepare_radar_context"

# Corpus structuré d’un mois pour le classement mensuel : sujets des radars,
# cartes, signaux et apprentissages du mois, plus le classement précédent, sans
# relire les livrables complets.
module WatchtowerClassementContext
  CONTRACT_SECTIONS = ["Preuves et dates", "Repères des notes", "Registre du classement mensuel", "Exécution économe"].freeze
  SIGNAL_FIELDS = %w[id identity_key canonical_url subject first_seen last_seen impact_architectural urgence
                     pertinence_stack confiance status decision classification deliverables].freeze
  LINK = /\[([^\]]+)\]\((https?:\/\/[^)]+)\)/.freeze

  module_function

  def month_range(month)
    first = Date.strptime(month, "%Y-%m")
    [first, Date.new(first.year, first.month, -1)]
  end

  def in_month?(value, first, last)
    date = Date.parse(value.to_s)
    date >= first && date <= last
  rescue ArgumentError
    false
  end

  def radar_subjects(text)
    rows = text.each_line.map do |line|
      next unless line.start_with?("| [")

      cells = line.strip.split("|").map(&:strip).reject(&:empty?)
      link = cells[0].match(LINK)
      next unless link

      { "name" => link[1], "canonical_url" => link[2], "type" => cells[1], "pitch" => cells[2] }
    end.compact
    return rows unless rows.empty?

    text.scan(/^## \[([^\]]+)\]\((https?:\/\/[^)]+)\)/).map { |name, url| { "name" => name, "canonical_url" => url } }
  end

  def carte_summary(text)
    title = text[/\A# (.+)$/, 1].to_s
    link = title.match(LINK)
    sources_section = text.split(/^## /).find { |section| section.start_with?("Sources consultées", "12. INCERTITUDES ET SOURCES") }.to_s
    {
      "title" => link ? link[1] : title.sub(/\ACARTE SERVICE — /, ""),
      "canonical_url" => link && link[2],
      "sources" => sources_section.scan(LINK).map { |label, url| { "label" => label, "url" => url } }.first(10)
    }
  end

  def ranking_rows(text)
    section = text.split(/^## /).find { |part| part.start_with?("Classement complet") }.to_s
    section.each_line.map do |line|
      cells = line.strip.split("|").map(&:strip)
      next unless cells.length >= 6 && cells[1].match?(/\A\d+\z/)

      link = cells[2].match(LINK)
      next unless link

      { "rank" => cells[1].to_i, "name" => link[1], "canonical_url" => link[2], "trend" => cells[4], "class" => cells[5] }
    end.compact
  end

  def ranking_register(text)
    block = text[/```yaml\s*watchtower-classement\s*\n(.*?)```/m, 1] || text[/watchtower-classement[^\n]*\n```yaml\n(.*?)```/m, 1]
    block && YAML.safe_load(block, permitted_classes: [Date])
  rescue Psych::Exception
    nil
  end

  def build(root:, month:)
    root = Pathname.new(root).expand_path
    first, last = month_range(month)
    corpus = []
    existing_edition = nil
    previous = nil
    root.glob("dist/*/*.md").sort.each do |path|
      relative = path.relative_path_from(root).to_s
      date = relative.split("/")[1]
      name = path.basename.to_s
      if name.start_with?("classement-mensuel-")
        covered = name[/classement-mensuel-(\d{4}-\d{2})/, 1]
        existing_edition = relative if covered == month
        previous = { "path" => relative, "period" => covered } if covered && covered < month && (previous.nil? || covered > previous["period"])
        next
      end
      next unless in_month?(date, first, last)

      text = path.read
      corpus << if name == "radar-architecture.md"
        { "date" => date, "path" => relative, "kind" => "radar", "subjects" => radar_subjects(text) }
      else
        { "date" => date, "path" => relative, "kind" => "carte" }.merge(carte_summary(text))
      end
    end
    if previous
      text = root.join(previous["path"]).read
      previous["items"] = ranking_rows(text)
      register = ranking_register(text)
      previous["register_items"] = Array(register["items"]).map { |item| item.select { |key, _| %w[id rank canonical_url classification trend score].include?(key) } } if register.is_a?(Hash)
    end
    signals = WatchtowerRadarContext.records(WatchtowerRadarContext.load_yaml(root.join("state/signals.yaml")), "signals", "signal_fields")
    month_signals = signals.select { |signal| in_month?(signal["first_seen"], first, last) || in_month?(signal["last_seen"], first, last) }
    learning = Array(WatchtowerRadarContext.load_yaml(root.join("state/learning.yaml"))["products"])
    {
      "schema_version" => 1,
      "period" => month,
      "from" => first.iso8601,
      "through" => last.iso8601,
      "existing_edition" => existing_edition,
      "corpus" => corpus,
      "signals" => month_signals.map { |signal| SIGNAL_FIELDS.to_h { |field| [field, WatchtowerRadarContext.iso(signal[field])] } },
      "learning" => learning.select { |entry| in_month?(entry["last_studied"], first, last) },
      "previous_ranking" => previous,
      "contract_excerpt" => WatchtowerContractSections.extract(root.join("docs/contrats-veille.md").read, CONTRACT_SECTIONS)
    }
  end
end

if $PROGRAM_NAME == __FILE__
  options = { root: Pathname.new(__dir__).join("..").expand_path, month: (Date.today << 1).strftime("%Y-%m") }
  OptionParser.new do |parser|
    parser.banner = "Usage: ruby scripts/prepare_classement_context.rb [--month YYYY-MM]"
    parser.on("--month YYYY-MM", "Mois couvert (défaut : mois précédent)") { |value| options[:month] = value }
    parser.on("--root PATH", "Racine du dépôt") { |value| options[:root] = Pathname.new(value) }
    parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
  end.parse!
  begin
    puts JSON.generate(WatchtowerClassementContext.build(root: options[:root], month: options[:month]))
  rescue WatchtowerRadarContext::Error, WatchtowerContractSections::Error, ArgumentError => e
    warn "ERREUR: #{e.message}"
    exit 2
  end
end
