require "google/apis/calendar_v3"
require "googleauth"

module Api
  class CalendarController < ApplicationController
    def events
      unless session[:google_token]
        return render json: { error: "Not authenticated" }, status: :unauthorized
      end

      client = Signet::OAuth2::Client.new(
        access_token: session[:google_token],
        refresh_token: session[:google_refresh_token],
        client_id: ENV["GOOGLE_CLIENT_ID"],
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: "https://accounts.google.com/o/oauth2/token"
      )

      # Refresh token if expired or about to expire
      begin
        client.refresh! if client.expired?
      rescue Signet::AuthorizationError => e
        Rails.logger.error("Token refresh failed: #{e.message}")
        return render json: { error: "Authentication expired, please login again" }, status: :unauthorized
      end

      # Update session with new token
      session[:google_token] = client.access_token
      session[:google_refresh_token] ||= client.refresh_token

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client

      calendar_id = "primary"
      start_time = params[:start_date] || Time.now.beginning_of_month.iso8601
      end_time   = params[:end_date] || Time.now.end_of_month.iso8601

      begin
        response = service.list_events(
          calendar_id,
          single_events: true,
          order_by: "startTime",
          time_min: start_time,
          time_max: end_time,
          max_results: 50
        )

        events = response.items.map do |event|
          {
            id: event.id,
            summary: event.summary,
            start: event.start&.date_time || event.start&.date,
            end: event.end&.date_time || event.end&.date,
            location: event.location,
            description: event.description
          }
        end

        render json: events
      rescue Google::Apis::AuthorizationError => e
        Rails.logger.error("Calendar authorization error: #{e.message}")
        render json: { error: "Failed to load events due to authorization" }, status: :unauthorized
      rescue => e
        Rails.logger.error("Calendar error: #{e.message}")
        render json: { error: "Failed to load events" }, status: :internal_server_error
      end
    end
  end
end
