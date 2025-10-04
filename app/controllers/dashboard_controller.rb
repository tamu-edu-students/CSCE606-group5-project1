class DashboardController < ApplicationController
  require "google/apis/calendar_v3"
  require "time"
  require "date"

  def show
    @current_event = nil
    @event_ends_at = nil
    @event_ends_at_formatted = nil
    @time_remaining_seconds = nil
    @time_remaining_hms = nil

    # If no Google session, render dashboard as before
    return unless session[:google_token]

    begin
      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = Signet::OAuth2::Client.new(
        access_token: session[:google_token],
        refresh_token: session[:google_refresh_token],
        client_id: ENV["GOOGLE_CLIENT_ID"],
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
      )

      # fetch a short window of events including current/ongoing ones
      now = Time.now.utc
      response = service.list_events(
        "primary",
        max_results: 20,
        single_events: true,
        order_by: "startTime",
        time_min: (now - 7 * 24 * 3600).iso8601,
        time_max: (now + 7 * 24 * 3600).iso8601
      )

      # find an event that contains `now`
      event = response.items.find do |e|
        start_time = e.start&.date_time || (e.start&.date && Time.parse(e.start.date))
        end_time = e.end&.date_time || (e.end&.date && Time.parse(e.end.date))
        start_time && end_time && now.between?(start_time, end_time)
      end

      if event
        @current_event = event
        if event.end&.date_time
          @event_ends_at = event.end.date_time.to_time.utc
        elsif event.end&.date
          @event_ends_at = Date.parse(event.end.date).to_time.utc
        end

        if @event_ends_at
          @event_ends_at_formatted = @event_ends_at.strftime("%d-%b-%Y %H:%M:%S")
          rem = (@event_ends_at - Time.now.utc).to_i
          rem = 0 if rem.negative?
          @time_remaining_seconds = rem
          h = rem / 3600
          m = (rem % 3600) / 60
          s = rem % 60
          @time_remaining_hms = format("%02d:%02d:%02d", h, m, s)
        end
      elsif session[:timer_ends_at]
        @timer_ends_at = Time.parse(session[:timer_ends_at])
        if @timer_ends_at <= Time.now.utc
          session.delete(:timer_ends_at)
          @timer_ends_at = nil
        else
          remaining_seconds = (@timer_ends_at - Time.current).to_i
          hours = remaining_seconds / 3600
          minutes = (remaining_seconds % 3600) / 60
          seconds = remaining_seconds % 60
          @time_remaining_hms = format("%02d:%02d:%02d", hours, minutes, seconds)
        end
      end
    rescue StandardError => e
      Rails.logger.info("Google Calendar fetch failed in Dashboard#show: #{e.class} #{e.message}")
    end
  end

   def create_timer
    minutes = params[:minutes].to_i
    if minutes > 0
      session[:timer_ends_at] = (Time.now.utc + minutes.minutes).iso8601
    end
    redirect_to dashboard_path
  end
end
