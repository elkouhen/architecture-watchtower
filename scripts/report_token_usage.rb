#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"

module WatchtowerTokenUsage
  class Error < StandardError; end

  TOKEN_LINE = /^> \*\*Tokens utilisés :\*\* .+$/

  module_function

  def extract(path)
    usages = []

    File.foreach(path).with_index(1) do |line, line_number|
      next if line.strip.empty?

      event = JSON.parse(line)
      raw = usage_from(event)
      usages << normalize(raw) if raw
    rescue JSON::ParserError => e
      raise Error, "JSONL invalide ligne #{line_number}: #{e.message}"
    end

    usage = usages.compact.last
    raise Error, "aucune consommation complète de tour dans #{path}" unless usage

    usage
  end

  def thread_id(path)
    File.foreach(path) do |line|
      next if line.strip.empty?

      event = JSON.parse(line)
      id = event["thread_id"] if event["type"] == "thread.started"
      id ||= event.dig("payload", "thread_id")
      return id if id.is_a?(String) && !id.empty?
    rescue JSON::ParserError
      next
    end
    nil
  end

  def session_for(thread_id, codex_home: nil)
    return nil if thread_id.to_s.empty?

    root = codex_home || ENV["CODEX_HOME"] || File.expand_path("~/.codex")
    Dir.glob(File.join(root, "sessions", "**", "rollout-*#{thread_id}.jsonl")).max
  end

  def inject(report, usage, duration_seconds: nil)
    path = Pathname.new(report)
    raise Error, "rapport absent: #{path}" unless path.file?
    raise Error, "seul un radar peut être instrumenté: #{path}" unless path.basename.to_s == "radar-architecture.md"

    text = path.read
    matches = text.lines.count { |line| line.match?(TOKEN_LINE) }
    raise Error, "une unique ligne de consommation est requise dans #{path}" unless matches == 1

    path.write(text.sub(TOKEN_LINE, render(usage, duration_seconds: duration_seconds)))
  end

  def render(usage, duration_seconds: nil)
    billed_input = usage.fetch(:input) - usage.fetch(:cached)
    duration = duration_seconds.nil? ? "" : ", durée `#{format_duration(duration_seconds)}`"
    "> **Tokens utilisés :** `#{usage.fetch(:total)}` total — entrée `#{usage.fetch(:input)}` " \
      "(dont cache `#{usage.fetch(:cached)}`, hors cache `#{billed_input}`), " \
      "sortie `#{usage.fetch(:output)}`, raisonnement `#{usage.fetch(:reasoning)}` — mesure runtime Codex#{duration}. " \
      "Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel."
  end

  def format_duration(duration_seconds)
    seconds = Integer(duration_seconds)
    raise Error, "durée invalide: #{duration_seconds.inspect}" if seconds.negative?

    hours, remainder = seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    format("%02d:%02d:%02d", hours, minutes, seconds)
  rescue ArgumentError, TypeError
    raise Error, "durée invalide: #{duration_seconds.inspect}"
  end

  def sum(*usages)
    keys = %i[input cached output reasoning total]
    keys.to_h { |key| [key, usages.sum { |usage| usage.fetch(key) }] }
  end

  def usage_from(event)
    case event["type"]
    when "turn.completed"
      event["usage"] || event.dig("payload", "usage")
    when "token_usage_record"
      event.dig("payload", "turn_token_usage")
    end
  end

  def normalize(raw)
    return nil unless raw.is_a?(Hash)

    input = integer(raw["input_tokens"])
    cached = integer(raw["cached_input_tokens"] || raw.dig("input_tokens_details", "cached_tokens"))
    output = integer(raw["output_tokens"])
    reasoning = integer(raw["reasoning_output_tokens"] || raw.dig("output_tokens_details", "reasoning_tokens"))
    total = integer(raw["total_tokens"])
    return nil unless [input, cached, output, reasoning, total].all?
    return nil unless total == input + output && cached <= input && reasoning <= output

    { input: input, cached: cached, output: output, reasoning: reasoning, total: total }
  end

  def integer(value)
    value if value.is_a?(Integer) && value >= 0
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  parser = OptionParser.new do |option_parser|
    option_parser.banner = "Usage: ruby scripts/report_token_usage.rb --report PATH (--events PATH | --session PATH)"
    option_parser.on("--report PATH", "Radar Markdown à instrumenter") { |value| options[:report] = value }
    option_parser.on("--events PATH", "Sortie JSONL de codex exec --json") { |value| options[:events] = value }
    option_parser.on("--session PATH", "Journal JSONL de session Codex") { |value| options[:session] = value }
    option_parser.on("-h", "--help", "Afficher cette aide") { puts option_parser; exit }
  end
  begin
    parser.parse!
  rescue OptionParser::ParseError => e
    warn "ERREUR: #{e.message}"
    warn parser
    exit 2
  end

  source = options[:events] || options[:session]
  abort "--report et --events ou --session sont requis" unless options[:report] && source

  begin
    usage = WatchtowerTokenUsage.extract(source)
    WatchtowerTokenUsage.inject(options[:report], usage)
    puts "Métriques Codex injectées: #{WatchtowerTokenUsage.render(usage)}"
  rescue WatchtowerTokenUsage::Error => e
    warn "ERREUR: #{e.message}"
    exit 1
  end
end
