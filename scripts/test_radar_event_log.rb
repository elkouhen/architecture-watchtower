# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "radar_event_log"

class RadarEventLogTest < Minitest::Test
  def setup
    @ticks = [10.0, 10.0, 12.5, 13.0]
    @output = StringIO.new
    @renderer = WatchtowerRadarEventLog::Renderer.new(
      io: @output,
      clock: -> { @ticks.shift || 13.0 },
      wall_clock: -> { Time.new(2026, 9, 9, 12, 34, 56) }
    )
  end

  def test_streams_command_start_and_completion_with_duration
    @renderer.consume(%q({"type":"item.started","item":{"id":"1","type":"command_execution","command":"rg foo"}}))
    @renderer.consume(%q({"type":"item.completed","item":{"id":"1","type":"command_execution","command":"rg foo","status":"completed","exit_code":0}}))

    assert_includes @output.string, "Début — Commande — rg foo"
    assert_includes @output.string, "Fin — Commande — rg foo — 3.0s, sortie 0"
  end

  def test_streams_web_and_progress_without_full_result
    @renderer.consume(%q({"type":"item.completed","item":{"id":"2","type":"web_search","query":"AWS releases","results":[{"snippet":"volumineux"}]}}))
    @renderer.consume(%q({"type":"item.completed","item":{"id":"3","type":"agent_message","text":"Qualification terminée"}}))

    assert_includes @output.string, "Fin — Web web — AWS releases"
    assert_includes @output.string, "Progression — Qualification terminée"
    refute_includes @output.string, "volumineux"
  end

  def test_reports_malformed_json_without_interrupting_the_stream
    @renderer.consume("not-json")

    assert_includes @output.string, "Événement JSON illisible"
  end
end
