# frozen_string_literal: true

require "minitest/autorun"
require_relative "radar_collectors/feed"

class RadarFeedCollectorTest < Minitest::Test
  def test_parses_rss_and_stops_at_last_item
    xml = <<~XML
      <rss><channel>
        <item><guid>new</guid><title>New</title><link>https://example.org/new</link><pubDate>Thu, 10 Sep 2026 08:00:00 GMT</pubDate><description>Change</description></item>
        <item><guid>known</guid><title>Known</title><link>https://example.org/known</link><pubDate>Wed, 09 Sep 2026 08:00:00 GMT</pubDate></item>
        <item><guid>old</guid><title>Old</title><link>https://example.org/old</link><pubDate>Tue, 08 Sep 2026 08:00:00 GMT</pubDate></item>
      </channel></rss>
    XML
    items = WatchtowerRadarCollectors::Feed.parse(xml)

    assert_equal 3, items.length
    assert_equal ["new"], WatchtowerRadarCollectors::Feed.delta(items, from: "2026-09-08", last_item_seen: "known").map { |item| item["id"] }
  end

  def test_parses_atom_link_attribute
    xml = <<~XML
      <feed xmlns="http://www.w3.org/2005/Atom">
        <entry><id>a</id><title>Release A</title><link href="https://example.org/a"/><updated>2026-09-10T08:00:00Z</updated><summary>Change</summary></entry>
      </feed>
    XML
    item = WatchtowerRadarCollectors::Feed.parse(xml).first

    assert_equal "a", item["id"]
    assert_equal "https://example.org/a", item["url"]
    assert_equal "2026-09-10T08:00:00Z", item["published_at"]
  end
end
