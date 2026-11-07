# frozen_string_literal: true

require "date"
require "fileutils"
require "net/http"
require "pathname"
require "uri"
require_relative "html_text"
require_relative "radar_collectors/feed"
require_relative "radar_source_registry"

# Collecte locale des sources du radar avant la qualification : chaque URL est
# téléchargée une fois, un flux RSS/Atom devient une liste d’éléments en delta,
# une page HTML devient un texte normalisé. Le contenu est écrit dans un cache
# non commité ; le modèle lit ensuite localement les seuls passages utiles.
module WatchtowerRadarCollection
  class Error < StandardError; end

  PAGE_MAX_CHARS = 300_000
  EXCERPT_CHARS = 120
  MAX_HEADINGS = 30
  MAX_ITEM_HEADINGS = 10
  DIGEST_MIN_CHARS = 1_500
  MAX_CONTEXT_ITEMS = 30
  ITEM_FIELDS = %w[published_at title url file excerpt headings].freeze
  DEFAULT_WINDOW_DAYS = 7
  MAX_WINDOW_DAYS = 30
  USER_AGENT = "architecture-watchtower/1.0"

  module_function

  def fetch(url, redirects: 3)
    raise Error, "trop de redirections" if redirects.negative?

    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = USER_AGENT
    request["Accept"] = "application/rss+xml, application/atom+xml, application/xml;q=0.9, text/html;q=0.8, */*;q=0.5"
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: 40) do |http|
      http.request(request)
    end
    case response
    when Net::HTTPSuccess then response.body.to_s.dup.force_encoding("UTF-8").scrub
    when Net::HTTPRedirection then fetch(URI.join(url, response.fetch("location")).to_s, redirects: redirects - 1)
    else raise Error, "HTTP #{response.code}"
    end
  rescue SystemCallError, IOError, Timeout::Error, OpenSSL::SSL::SSLError, SocketError, URI::Error => e
    raise Error, e.message
  end

  # sources : enregistrements du registre ; feeds : { id => URL de flux }.
  # Les chemins de cache rendus sont relatifs à root.
  def collect(sources, date:, root:, cache_dir:, feeds: {}, fetcher: method(:fetch), window_days: DEFAULT_WINDOW_DAYS)
    root = Pathname.new(root)
    cache_dir = Pathname.new(cache_dir)
    FileUtils.mkdir_p(root.join(cache_dir))
    bodies = {}
    sources.map do |source|
      primary = feeds[source["id"]] || source["url"]
      urls = [primary, source["fallback"]].compact.map(&:to_s).reject(&:empty?).uniq
      last_success = to_date(source["last_success"])
      from = last_success || (date - window_days)
      result = { "source_id" => source["id"], "from" => from.iso8601, "through" => date.iso8601, "status" => "failed", "attempts" => [] }
      if from < date - MAX_WINDOW_DAYS
        # Une interruption de plus de trente jours laisse une lacune explicitement datée.
        result["gap"] = { "from" => from.iso8601, "through" => (date - MAX_WINDOW_DAYS - 1).iso8601 }
        from = date - MAX_WINDOW_DAYS
        result["from"] = from.iso8601
      end
      urls.each do |url|
        body = bodies[url] ||= begin
          fetcher.call(url)
        rescue Error, StandardError => e
          e
        end
        if body.is_a?(Exception)
          result["attempts"] << { "url" => url, "error" => body.message }
          next
        end
        result.merge!(describe(body, url, source, from, root, cache_dir))
        break
      end
      result
    end
  end

  def describe(body, url, source, from, root, cache_dir)
    items = feed_items(body)
    if items
      delta = WatchtowerRadarCollectors::Feed.delta(items, from: from, last_item_seen: source["last_item_seen"])
      dir = cache_dir.join(source["id"])
      FileUtils.mkdir_p(root.join(dir))
      index_lines = []
      entries = delta.each_with_index.map do |item, index|
        text = WatchtowerHtmlText.convert(item["summary"], max_chars: PAGE_MAX_CHARS)
        path = dir.join(format("%03d-%s.md", index + 1, slug(item["title"])))
        root.join(path).write("# #{item['title']}\n\nURL : #{item['url']}\nPublié : #{item['published_at']}\nSource : #{source['id']}\n\n#{text}\n")
        index_lines << "| #{item['published_at'].to_s[0, 10]} | #{item['title'].to_s.gsub('|', '/')} | #{item['url']} | #{path} |"
        # Un élément long (digest quotidien) expose ses titres internes ; un élément court, seulement son extrait.
        headings = text.length >= DIGEST_MIN_CHARS ? WatchtowerHtmlText.headings(text, limit: MAX_ITEM_HEADINGS) : []
        [
          item["published_at"].to_s[0, 10], item["title"], item["url"], path.basename.to_s,
          WatchtowerHtmlText.excerpt(text, chars: EXCERPT_CHARS), headings
        ]
      end
      index_path = dir.join("index.md")
      root.join(index_path).write("# Delta #{source['id']} du #{from.iso8601}\n\n| Publié | Titre | URL | Fichier |\n|---|---|---|---|\n#{index_lines.join("\n")}\n")
      {
        "status" => "ok", "kind" => "feed", "url" => url, "feed_items" => items.length,
        "latest_item_id" => items.first["id"], "cache_dir" => dir.to_s, "index_path" => index_path.to_s,
        "items_total" => entries.length, "items_omitted_from_context" => [entries.length - MAX_CONTEXT_ITEMS, 0].max,
        "item_fields" => ITEM_FIELDS, "items" => entries.first(MAX_CONTEXT_ITEMS)
      }
    else
      text = WatchtowerHtmlText.convert(body, max_chars: PAGE_MAX_CHARS)
      path = cache_dir.join("#{source['id']}.md")
      root.join(path).write("# #{source['name'] || source['id']}\n\nURL : #{url}\nSource : #{source['id']}\n\n#{text}\n")
      {
        "status" => "ok", "kind" => "page", "url" => url, "cache_path" => path.to_s, "chars" => text.length,
        "truncated" => text.end_with?("[tronqué]"),
        "headings" => WatchtowerHtmlText.headings(text, limit: MAX_HEADINGS),
        "excerpt" => WatchtowerHtmlText.excerpt(text, chars: EXCERPT_CHARS)
      }
    end
  end

  def feed_items(body)
    return nil unless body.lstrip.start_with?("<?xml", "<rss", "<feed")

    items = WatchtowerRadarCollectors::Feed.parse(body)
    items.empty? ? nil : items
  rescue ArgumentError
    nil
  end

  # Avance les curseurs du registre selon le résultat réel de chaque collecte.
  def update_registry(registry_path, results, date:)
    results.each do |result|
      attributes = { "last_attempt" => date.iso8601 }
      case [result["status"], result["kind"]]
      when %w[ok feed]
        attributes.merge!(
          "last_success" => date.iso8601, "status" => "ok",
          "last_item_seen" => result["latest_item_id"],
          "notes" => "Collecte structurée du flux le #{date.iso8601} : #{result['items_total']} élément(s) en delta."
        )
      when %w[ok page]
        attributes["notes"] = "Page capturée localement le #{date.iso8601} (#{result['chars']} caractères) ; delta à confirmer par la qualification."
      else
        errors = result["attempts"].map { |attempt| "#{attempt['url']} : #{attempt['error']}" }.join(" ; ")
        attributes.merge!("status" => "failed", "notes" => "Collecte en échec le #{date.iso8601} : #{errors}")
      end
      WatchtowerRadarSourceRegistry.update(registry_path, result["source_id"], attributes)
    end
  end

  def slug(value)
    text = value.to_s.unicode_normalize(:nfkd).encode("ASCII", replace: "").downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
    text.empty? ? "item" : text[0, 60]
  end

  def to_date(value)
    return nil if value.to_s.strip.empty?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
