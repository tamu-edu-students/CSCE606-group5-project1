# spec/requests/calendar_events_spec.rb
require "rails_helper"

RSpec.describe "Calendar Events (Google Calendar integration)", type: :request do
  let(:service_double) { instance_double(Google::Apis::CalendarV3::CalendarService) }

  let(:fake_event) do
    Google::Apis::CalendarV3::Event.new(
      id: "evt_123",
      summary: "Test",
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: Time.zone.parse("2025-10-02 10:00").iso8601),
      end:   Google::Apis::CalendarV3::EventDateTime.new(date_time: Time.zone.parse("2025-10-02 10:30").iso8601)
    )
  end

  before do
    # 1) Bypass login redirection so we don’t get bounced to root_path
    allow_any_instance_of(ApplicationController)
      .to receive(:authenticate_user!)
      .and_return(true)

    # 2) Bypass the Google auth/service builder so no network/token logic runs
    allow_any_instance_of(Api::CalendarController)
      .to receive(:calendar_service_or_unauthorized)
      .and_return(service_double)
  end

  describe "POST /api/calendar_events" do
    it "creates a timed event and redirects with a flash notice" do
      allow(service_double).to receive(:insert_event).and_return(fake_event)

      post api_calendar_events_path,
           params: { event: { summary: "Test", start_date: "2025-10-02", start_time: "10:00" } }

      expect(response).to redirect_to(calendar_path)  # <- will pass now
      follow_redirect!
      expect(response.body).to include("Event created").or include("Event successfully created")
    end

    it "creates an all-day event" do
      allow(service_double).to receive(:insert_event).and_return(
        Google::Apis::CalendarV3::Event.new(
          id: "evt_all_day",
          summary: "All Day",
          start: Google::Apis::CalendarV3::EventDateTime.new(date: "2025-10-03"),
          end:   Google::Apis::CalendarV3::EventDateTime.new(date: "2025-10-04")
        )
      )

      post api_calendar_events_path,
           params: { event: { summary: "All Day", all_day: "1", start_date: "2025-10-03" } }

      expect(response).to redirect_to(calendar_path)
      follow_redirect!
      expect(response.body).to include("Event created").or include("Event successfully created")
    end
  end

  describe "PATCH /api/calendar_events/:id" do
    it "updates an event time" do
      allow(service_double).to receive(:get_event).with("primary", "evt_123").and_return(fake_event)
      allow(service_double).to receive(:update_event).and_return(fake_event)

      patch api_calendar_event_path("evt_123"),
            params: { event: { start_date: "2025-10-02", start_time: "11:00", end_time: "11:30" } }

      expect(response).to redirect_to(calendar_path)
      follow_redirect!
      expect(response.body).to include("Event updated")
    end

    it "toggles to all-day" do
      allow(service_double).to receive(:get_event).with("primary", "evt_123").and_return(fake_event)
      allow(service_double).to receive(:update_event).and_return(
        Google::Apis::CalendarV3::Event.new(
          id: "evt_123",
          summary: "Test",
          start: Google::Apis::CalendarV3::EventDateTime.new(date: "2025-10-05"),
          end:   Google::Apis::CalendarV3::EventDateTime.new(date: "2025-10-06")
        )
      )

      patch api_calendar_event_path("evt_123"),
            params: { event: { all_day: "1", start_date: "2025-10-05" } }

      expect(response).to redirect_to(calendar_path)
      follow_redirect!
      expect(response.body).to include("Event updated")
    end
  end

  describe "DELETE /api/calendar_events/:id" do
    it "deletes an event and redirects with notice" do
      allow(service_double).to receive(:delete_event).with("primary", "evt_123").and_return(true)

      delete api_calendar_event_path("evt_123")

      expect(response).to redirect_to(calendar_path)
      follow_redirect!
      expect(response.body).to include("Event deleted")
    end
  end
end
