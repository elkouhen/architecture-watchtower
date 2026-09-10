#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "net/http"
require "optparse"
require "pathname"
require "uri"
require "yaml"
require_relative "radar_collectors/feed"
require_relative "radar_source_registry"

ROOT = Pathname.new(__dir__).join("..").expand_path
options = { registry: ROOT.join("state/sources.yaml"), date: Date.today }
OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/collect_radar_source.rb --source ID [--from YYYY-MM-DD]"
  parser.on("--source ID", "Identifiant de la source") { |value| options[:source] = value }
  parser.on("--from DATE", "Borne de reprise explicite") { |value| options[:from] = value }
  parser.on("--registry PATH", "Registre des sources") { |value| options[:registry] = Pathname.new(value) }
  parser.on("--date DATE", "Date de la collecte") { |value| options[:date] = Date.iso8601(value) }
  parser.on("--update-registry", "Mettre à jour les curseurs de la source") { options[:update_registry] = true }
  parser.on("-h", "--help", "Afficher cette aide") { puts parser; exit }
end.parse!
abort "--source est requis" unless options[:source]

def records(data)
  rows = data.fetch("sources", [])
  return rows unless data["format"] == "tabular-v1"
  fields = data.fetch("source_fields")
  rows.map { |row| fields.zip(row).to_h }
end

def fetch(uri, redirects = 3)
  raise "trop de redirections" if redirects.negative?
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "architecture-watchtower/1.0"
  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 20) do |http|
    http.request(request)
  end
  case response
  when Net::HTTPSuccess then response.body
  when Net::HTTPRedirection
    fetch(URI.join(uri.to_s, response.fetch("location")), redirects - 1)
  else
    raise "HTTP #{response.code}"
  end
end

begin
  registry_path = options[:registry].expand_path(ROOT)
  data = YAML.safe_load(registry_path.read, permitted_classes: [Date, Time], aliases: true) || {}
  source = records(data).find { |item| item["id"] == options[:source] }
  abort "Source inconnue: #{options[:source]}" unless source
  urls = [source["url"], source["fallback"]].compact.uniq
  errors = []
  items = nil
  used_url = nil
  urls.first(2).each do |url|
    begin
      items = WatchtowerRadarCollectors::Feed.parse(fetch(URI(url)))
      raise "aucune entrée RSS ou Atom détectée" if items.empty?
      used_url = url
      break
    rescue StandardError => e
      errors << { "url" => url, "error" => e.message }
    end
  end
  raise "source et fallback en échec" unless items
  delta = WatchtowerRadarCollectors::Feed.delta(
    items,
    from: options[:from] || source["last_success"],
    last_item_seen: source["last_item_seen"]
  )
  if options[:update_registry]
    status = errors.empty? ? "ok" : "degraded"
    note = if errors.empty?
      "Collecte structurée réussie le #{options[:date]}."
    else
      "Collecte structurée réussie via fallback le #{options[:date]} après échec de la source principale."
    end
    WatchtowerRadarSourceRegistry.update(registry_path, source["id"], {
      "last_attempt" => options[:date].iso8601,
      "last_success" => options[:date].iso8601,
      "last_item_seen" => items.first["id"] || source["last_item_seen"],
      "status" => status,
      "notes" => note
    })
  end
  puts JSON.pretty_generate({
    "source_id" => source["id"], "url" => used_url, "attempted_at" => Time.now.iso8601,
    "from" => options[:from] || source["last_success"], "last_item_seen" => source["last_item_seen"],
    "items" => delta, "errors" => errors
  })
rescue Psych::Exception, ArgumentError, RuntimeError, WatchtowerRadarSourceRegistry::Error => e
  if options[:update_registry] && defined?(registry_path) && defined?(source) && source
    begin
      WatchtowerRadarSourceRegistry.update(registry_path, source["id"], {
        "last_attempt" => options[:date].iso8601,
        "status" => "failed",
        "notes" => "Collecte structurée en échec le #{options[:date]} : #{e.message}"
      })
    rescue WatchtowerRadarSourceRegistry::Error => registry_error
      warn "ERREUR registre: #{registry_error.message}"
    end
  end
  warn "ERREUR: #{e.message}"
  exit 1
end
