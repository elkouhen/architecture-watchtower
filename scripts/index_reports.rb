#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "optparse"
require "pathname"

# Mise à jour mécanique de docs/rapports.md et de la navigation récente de README.md.
module WatchtowerReportIndex
  MONTHS = %w[janvier février mars avril mai juin juillet août septembre octobre novembre décembre].freeze
  README_RECENT_RADARS = 10

  module_function

  def french_date(date)
    "#{date.day} #{MONTHS[date.month - 1]} #{date.year}"
  end

  def add_radar(root:, date:)
    root = Pathname.new(root)
    relative = "dist/#{date.iso8601}/radar-architecture.md"
    update_rapports(root.join("docs/rapports.md"), date, "- [Radar architecture](../#{relative})")
    update_readme(root.join("README.md"), "- [Radar du #{french_date(date)}](#{relative})")
    relative
  end

  def update_rapports(path, date, entry)
    lines = path.read.lines
    heading = "## #{french_date(date)}\n"
    index = lines.index(heading)
    if index
      return if lines[index..].take_while.with_index { |line, offset| offset.zero? || !line.start_with?("## ") }.include?("#{entry}\n")

      lines.insert(index + 2, "#{entry}\n")
    else
      first = lines.index { |line| line.start_with?("## ") } || lines.length
      lines.insert(first, heading, "\n", "#{entry}\n", "\n")
    end
    path.write(lines.join)
  end

  def update_readme(path, entry)
    lines = path.read.lines
    return if lines.include?("#{entry}\n")

    anchor = lines.index { |line| line.start_with?("- [Radar du ") } ||
      (lines.index { |line| line.start_with?("- Classement mensuel :") }&.+(1)) ||
      lines.index { |line| line.start_with?("## Livrables") }&.+(2)
    raise "README.md: section Livrables introuvable" unless anchor

    lines.insert(anchor, "#{entry}\n")
    kept = 0
    lines = lines.reject do |line|
      next false unless line.start_with?("- [Radar du ")

      kept += 1
      kept > README_RECENT_RADARS
    end
    path.write(lines.join)
  end
end

if $PROGRAM_NAME == __FILE__
  options = { root: Pathname.new(__dir__).join("..").expand_path, date: Date.today }
  OptionParser.new do |parser|
    parser.banner = "Usage: ruby scripts/index_reports.rb --date YYYY-MM-DD"
    parser.on("--date YYYY-MM-DD", "Date du radar") { |value| options[:date] = Date.iso8601(value) }
    parser.on("--root PATH", "Racine du dépôt") { |value| options[:root] = Pathname.new(value) }
    parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
  end.parse!
  puts "Index mis à jour : #{WatchtowerReportIndex.add_radar(root: options[:root], date: options[:date])}"
end
