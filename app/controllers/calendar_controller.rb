require "google/apis/calendar_v3"
require "googleauth"

class CalendarController < ApplicationController
  def show
    unless session[:google_token]
      flash.now[:alert] = "Not authenticated with Google. Please log in."
      @events = []
      return
    end

    client = Signet::OAuth2::Client.new(
      access_token: session[:google_token],
      refresh_token: session[:google_refresh_token],
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      token_credential_uri: "https://oauth2.googleapis.com/token"

    )

    begin
      client.refresh! if client.expired?
      session[:google_token] = client.access_token
      session[:google_refresh_token] ||= client.refresh_token
    rescue Signet::AuthorizationError => e
      Rails.logger.error("Token refresh failed: #{e.message}")
      flash.now[:alert] = "Authentication expired. Please log in again."
      @events = []
      return
    end

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    @current_date = params[:date] ? Date.parse(params[:date]) : Date.today

    start_time = @current_date.beginning_of_month.beginning_of_day.utc.iso8601
    end_time   = @current_date.end_of_month.end_of_day.utc.iso8601

    begin
      response = service.list_events("primary", single_events: true, order_by: "startTime", time_min: start_time, time_max: end_time)

      @events = response.items.map do |event|
        is_all_day = event.start.date_time.nil?
        if is_all_day
          start_date_source = event.start.date
          end_date_source   = event.end.date

          start_time = start_date_source.is_a?(Date) ? start_date_source : Date.parse(start_date_source)
          end_time   = end_date_source.is_a?(Date) ? end_date_source : Date.parse(end_date_source)
        else
          start_time = event.start.date_time
          end_time   = event.end.date_time
        end

        { 
          id: event.id,
          summary: event.summary,
          start: start_time,
          end: end_time,
          is_all_day: is_all_day
        }
      end
    rescue => e
      Rails.logger.error("Calendar error: #{e.message}")
      flash.now[:alert] = "Failed to load calendar events."
      @events = []
    end
  end
  def edit
    service = calendar_service_or_unauthorized or return
    
    begin
      event = service.get_event("primary", params[:id])
      @event = {
        id: event.id,
        summary: event.summary,
        description: event.description,
        location: event.location,
        start: event.start.date_time || event.start.date,
        end: event.end.date_time || event.end.date,
        is_all_day: event.start.date_time.nil?
      }
    rescue Google::Apis::ClientError => e
      error_message = e.respond_to?(:message) ? e.message : "Failed to load event"
      Rails.logger.error("Failed to fetch event: #{error_message}")
      redirect_to calendar_path, alert: error_message
    end
  end
  private
   def calendar_service_or_unauthorized
      unless session[:google_token].present?
        redirect_to login_google_path, alert: "Please log in with Google to continue."
        return nil
      end

      client = Signet::OAuth2::Client.new(
        access_token:         session[:google_token],
        refresh_token:        session[:google_refresh_token],
        client_id:            ENV["GOOGLE_CLIENT_ID"],
        client_secret:        ENV["GOOGLE_CLIENT_SECRET"],
        token_credential_uri: "https://oauth2.googleapis.com/token"
      )

      # Refresh if expired / near expiry (2 minutes)
      begin
        if client.respond_to?(:expires_at)
          client.refresh! if client.expired? || client.expires_at.to_i <= (Time.now + 120).to_i
        else
          client.refresh! if client.expired?
        end
      rescue Signet::AuthorizationError => e
        Rails.logger.error("Token refresh failed: #{e.message}")
        reset_session
        redirect_to login_google_path, alert: "Authentication expired, please log in again." 
        return
      end

      session[:google_token]          = client.access_token
      session[:google_refresh_token] ||= client.refresh_token

      service = Google::Apis::CalendarV3::CalendarService.new
      service.authorization = client
      service
    end

end
