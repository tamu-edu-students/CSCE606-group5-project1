class GoogleCalendarHelper
require 'webmock/rspec'
require 'vcr'
  def initialize
    @service = Google::Apis::CalendarV3::CalendarService.new
    # Mock authentication for testing
    @service.authorization = 'fake_token'
  end

  def create_event
    event = Google::Apis::CalendarV3::Event.new(
      summary: 'Test Event',
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: Time.now.iso8601,
        time_zone: 'America/Chicago'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: (Time.now + 1.hour).iso8601,
        time_zone: 'America/Chicago'
      )
    )
    @service.insert_event('primary', event)
  end

  def read_event(event_id)
    @service.get_event('primary', event_id)
  end

  def update_event(event_id, updates)
    event = read_event(event_id)
    updates.each do |key, value|
      event.send("#{key}=", value)
    end
    @service.update_event('primary', event_id, event)
  end

  def delete_event(event_id)
    @service.delete_event('primary', event_id)
  end
  VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
end
