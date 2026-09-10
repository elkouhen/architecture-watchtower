# frozen_string_literal: true

require "date"
require "rexml/document"
require "time"

module WatchtowerRadarCollectors
  module Feed
    module_function

    def parse(xml)
      document = REXML::Document.new(xml)
      elements = []
      document.root.each_element("//*") { |element| elements << element if %w[item entry].include?(element.name) }
      elements.map do |element|
        link_element = child(element, "link")
        link = if link_element && !link_element.attributes["href"].to_s.empty?
          link_element.attributes["href"]
        else
          link_element && link_element.text
        end
        raw_date = text(element, %w[pubDate published updated date])
        {
          "id" => text(element, %w[guid id]) || link,
          "title" => text(element, ["title"]),
          "url" => link.to_s.strip,
          "published_at" => normalize_time(raw_date),
          "summary" => text(element, %w[description summary content])
        }
      end
    rescue REXML::ParseException => e
      raise ArgumentError, "flux XML invalide: #{e.message}"
    end

    def delta(items, from:, last_item_seen: nil)
      cutoff = from && Date.parse(from.to_s)
      result = []
      items.each do |item|
        break if last_item_seen && item["id"] == last_item_seen
        published = item["published_at"] && Date.parse(item["published_at"])
        next if cutoff && published && published < cutoff
        result << item
      rescue Date::Error
        result << item
      end
      result
    end

    def child(element, name)
      element.elements.to_a.find { |candidate| candidate.name == name }
    end

    def text(element, names)
      found = element.elements.to_a.find { |candidate| names.include?(candidate.name) }
      value = found && found.texts.map(&:value).join(" ").strip
      value unless value.to_s.empty?
    end

    def normalize_time(value)
      return nil if value.to_s.strip.empty?
      Time.parse(value).iso8601
    rescue ArgumentError
      value
    end
  end
end
