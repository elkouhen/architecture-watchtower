# frozen_string_literal: true

require "json"

module WatchtowerRadarEventLog
  class Renderer
    MAX_DETAIL = 220

    def initialize(io: $stdout, clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }, wall_clock: -> { Time.now })
      @io = io
      @clock = clock
      @wall_clock = wall_clock
      @started_at = @clock.call
      @items = {}
      @io.sync = true if @io.respond_to?(:sync=)
    end

    def phase(message)
      emit(message)
    end

    def consume(line)
      event = JSON.parse(line)
      case event["type"]
      when "thread.started"
        emit("Codex démarré", short_id(event["thread_id"]))
      when "turn.started"
        emit("Tour démarré")
      when "item.started"
        item_started(event["item"] || {})
      when "item.completed"
        item_completed(event["item"] || {})
      when "item.failed"
        item_completed(event["item"] || {}, failed: true)
      when "turn.completed"
        emit("Tour terminé", usage(event["usage"]))
      when "turn.failed", "error"
        emit("ERREUR Codex", detail(event["error"] || event["message"] || event))
      end
    rescue JSON::ParserError => e
      emit("Événement JSON illisible", e.message)
    end

    private

    def item_started(item)
      @items[item["id"]] = @clock.call if item["id"]
      label, value = describe(item)
      emit("Début — #{label}", value) if label && label != "Progression"
    end

    def item_completed(item, failed: false)
      label, value = describe(item)
      return unless label

      started = item["id"] && @items.delete(item["id"])
      duration = started ? format("%.1fs", @clock.call - started) : nil
      if label == "Progression"
        emit(label, value)
        return
      end

      status = failed || item["status"] == "failed" ? "Échec" : "Fin"
      suffix = [duration, result(item)].compact.join(", ")
      emit("#{status} — #{label}", [value, suffix].reject(&:empty?).join(" — "))
    end

    def describe(item)
      type = item["type"].to_s.downcase.delete("_")
      case type
      when "agentmessage"
        ["Progression", text_content(item)]
      when "commandexecution"
        ["Commande", detail(command(item))]
      when "mcp_tool_call", "mcptoolcall"
        ["Outil MCP", detail([item["server"], item["tool"]].compact.join("/"))]
      when "websearch", "extension"
        action = item.dig("action", "type") || item["kind"] || "web"
        value = item["query"] || item.dig("action", "url") || Array(item.dig("action", "queries")).join(" | ")
        ["Web #{action}", detail(value)]
      when "filechange", "filechanges"
        ["Modification de fichiers", detail(Array(item["changes"]).map { |change| change["path"] || change }.join(", "))]
      when "reasoning"
        [nil, nil]
      else
        ["Action #{item['type'] || 'inconnue'}", nil]
      end
    end

    def command(item)
      value = item["command"]
      value.is_a?(Array) ? value.last : value
    end

    def text_content(item)
      direct = item["text"]
      return detail(direct) unless direct.to_s.empty?

      texts = Array(item["content"]).filter_map { |entry| entry["text"] if entry.is_a?(Hash) }
      detail(texts.join(" "))
    end

    def result(item)
      return "sortie #{item['exit_code']}" unless item["exit_code"].nil?
      return item["status"] if item["status"] && item["status"] != "completed"

      nil
    end

    def usage(value)
      return nil unless value.is_a?(Hash)

      input = value["input_tokens"]
      output = value["output_tokens"]
      return nil unless input || output

      "tokens entrée #{input || '?'}, sortie #{output || '?'}"
    end

    def short_id(value)
      value.to_s.empty? ? nil : "thread #{value.to_s[0, 8]}"
    end

    def detail(value)
      text = value.is_a?(String) ? value : value.to_json
      compact = text.gsub(/\s+/, " ").strip
      compact.length > MAX_DETAIL ? "#{compact[0, MAX_DETAIL - 1]}…" : compact
    end

    def emit(message, value = nil)
      elapsed = @clock.call - @started_at
      timestamp = @wall_clock.call.strftime("%H:%M:%S")
      suffix = value.to_s.empty? ? "" : " — #{value}"
      @io.puts format("[%s +%6.1fs] %s%s", timestamp, elapsed, message, suffix)
    end
  end
end
