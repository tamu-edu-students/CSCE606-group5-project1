require "rails_helper"
require "ostruct"
require "time"

RSpec.describe "GoogleCalendar.in_event?" do
  let(:now) { Time.utc(2025, 9, 24, 12, 0, 0) }

  it "returns true when current time is within an event with date_time start/end" do
    event = OpenStruct.new(
      start: OpenStruct.new(date_time: (now - 3600).iso8601),
      end:   OpenStruct.new(date_time: (now + 3600).iso8601)
    )

    expect(GoogleCalendar.in_event?(event, now)).to be true
  end

  it "returns false when current time is before the event" do
    event = OpenStruct.new(
      start: OpenStruct.new(date_time: (now + 3600).iso8601),
      end:   OpenStruct.new(date_time: (now + 7200).iso8601)
    )

    expect(GoogleCalendar.in_event?(event, now)).to be false
  end

  it "returns false when current time is after the event" do
    event = OpenStruct.new(
      start: OpenStruct.new(date_time: (now - 7200).iso8601),
      end:   OpenStruct.new(date_time: (now - 3600).iso8601)
    )

    expect(GoogleCalendar.in_event?(event, now)).to be false
  end

  it "handles all-day events (start.date / end.date). Google end.date is exclusive" do
    # Event that covers 2025-09-24 only (end.date is exclusive and set to 2025-09-25)
    event = OpenStruct.new(
      start: OpenStruct.new(date: "2025-09-24"),
      end:   OpenStruct.new(date: "2025-09-25")
    )

    expect(GoogleCalendar.in_event?(event, now)).to be true

    # A time on the day after should be false
    after = Time.utc(2025, 9, 25, 12, 0, 0)
    expect(GoogleCalendar.in_event?(event, after)).to be false
  end
end
