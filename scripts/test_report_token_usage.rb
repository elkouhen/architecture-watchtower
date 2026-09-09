# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "report_token_usage"

class ReportTokenUsageTest < Minitest::Test
  def write_jsonl(path, events)
    File.write(path, events.map(&:to_json).join("\n") + "\n")
  end

  def complete_usage
    {
      "input_tokens" => 120,
      "cached_input_tokens" => 80,
      "output_tokens" => 30,
      "reasoning_output_tokens" => 10,
      "total_tokens" => 150
    }
  end

  def test_extracts_last_complete_turn_usage
    Dir.mktmpdir("watchtower-token-test-") do |dir|
      events = File.join(dir, "events.jsonl")
      write_jsonl(events, [
        { "type" => "turn.completed", "usage" => complete_usage.merge("total_tokens" => 999) },
        { "type" => "turn.completed", "usage" => complete_usage }
      ])

      assert_equal({ input: 120, cached: 80, output: 30, reasoning: 10, total: 150 }, WatchtowerTokenUsage.extract(events))
    end
  end

  def test_extracts_persisted_session_usage
    Dir.mktmpdir("watchtower-token-test-") do |dir|
      events = File.join(dir, "session.jsonl")
      write_jsonl(events, [{
        "type" => "token_usage_record",
        "payload" => { "turn_token_usage" => complete_usage }
      }])

      assert_equal 150, WatchtowerTokenUsage.extract(events)[:total]
    end
  end

  def test_extracts_official_nested_usage_details
    Dir.mktmpdir("watchtower-token-test-") do |dir|
      events = File.join(dir, "events.jsonl")
      write_jsonl(events, [{
        "type" => "turn.completed",
        "usage" => {
          "input_tokens" => 120,
          "input_tokens_details" => { "cached_tokens" => 80 },
          "output_tokens" => 30,
          "output_tokens_details" => { "reasoning_tokens" => 10 },
          "total_tokens" => 150
        }
      }])

      assert_equal 80, WatchtowerTokenUsage.extract(events)[:cached]
      assert_equal 10, WatchtowerTokenUsage.extract(events)[:reasoning]
    end
  end

  def test_rejects_thread_wide_usage
    Dir.mktmpdir("watchtower-token-test-") do |dir|
      events = File.join(dir, "events.jsonl")
      write_jsonl(events, [{
        "type" => "event_msg",
        "payload" => { "type" => "token_count", "info" => { "total_token_usage" => complete_usage } }
      }])

      assert_raises(WatchtowerTokenUsage::Error) { WatchtowerTokenUsage.extract(events) }
    end
  end

  def test_finds_session_from_thread_event
    Dir.mktmpdir("watchtower-token-test-") do |dir|
      events = File.join(dir, "events.jsonl")
      thread_id = "thread-123"
      write_jsonl(events, [{ "type" => "thread.started", "thread_id" => thread_id }])
      session_dir = File.join(dir, "sessions", "2026", "09", "07")
      FileUtils.mkdir_p(session_dir)
      session = File.join(session_dir, "rollout-2026-09-07T10-00-00-#{thread_id}.jsonl")
      write_jsonl(session, [{ "type" => "token_usage_record", "payload" => { "turn_token_usage" => complete_usage } }])

      assert_equal thread_id, WatchtowerTokenUsage.thread_id(events)
      assert_equal session, WatchtowerTokenUsage.session_for(thread_id, codex_home: dir)
    end
  end

  def test_injects_detailed_metrics_in_radar
    Dir.mktmpdir("watchtower-token-test-") do |dir|
      report = File.join(dir, "radar-architecture.md")
      File.write(report, <<~MD)
        # Radar
        <!-- watchtower:2 -->
        > **Tokens utilisés :** `non disponible` — compteur runtime non exposé.
      MD

      WatchtowerTokenUsage.inject(report, WatchtowerTokenUsage.normalize(complete_usage))

      assert_includes File.read(report),
        "`150` total — entrée `120` (dont cache `80`, hors cache `40`), sortie `30`, raisonnement `10`"
    end
  end
end
