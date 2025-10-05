require "google/apis/calendar_v3"
require "googleauth"

class CalendarController < ApplicationController
  before_action :authenticate_user!

  def show
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.today

    service = calendar_service_or_unauthorized
    unless service
      flash.now[:alert] = "Not authenticated with Google. Please log in."
      @events = []
      return
    end

    start_time = @current_date.beginning_of_month.beginning_of_day.utc.iso8601
    end_time   = @current_date.end_of_month.end_of_day.utc.iso8601

    begin
      response = service.list_events("primary", single_events: true, order_by: "startTime", time_min: start_time, time_max: end_time)

      @events = response.items.map do |event|
        is_all_day = event.start.date_time.nil?
        if is_all_day
          start_date = parse_date(event.start.date)
          end_date   = parse_date(event.end.date)
        else
          start_date = event.start.date_time
          end_date   = event.end.date_time
        end

        {
          id: event.id,
          summary: event.summary,
          start: start_date,
          end: end_date,
          is_all_day: is_all_day
        }
      end
    rescue => e
      Rails.logger.error("Calendar error: #{e.message}")
      flash.now[:alert] = "Failed to load calendar events."
      @events = []
    end
  end

  def sync
    result = GoogleCalendarSync.sync_for_user(current_user, session)

    if result[:success]
      flash[:notice] = "Calendar synced successfully! " \
                       "#{result[:synced]} created, " \
                       "#{result[:updated]} updated, " \
                       "#{result[:deleted]} deleted."
      Rails.logger.info("Calendar sync for user #{current_user.id}: #{result}")
    else
      flash[:alert] = "Sync failed: #{result[:error]}"
    end

    redirect_back(fallback_location: calendar_path)
  end

  def new
    @event = Google::Apis::CalendarV3::Event.new
  end

  def edit
    service = calendar_service_or_unauthorized or return

    begin
      event = service.get_event("primary", params[:id])
      is_all_day = event.start.date_time.nil?

      start_time = if is_all_day
               DateTime.parse("#{event.start.date} 00:00")
      else
               event.start.date_time
      end

      end_time = if is_all_day
             DateTime.parse("#{event.end.date} 00:00")
      else
             event.end.date_time
      end

      @event = {
        id: event.id,
        summary: event.summary,
        description: event.description,
        location: event.location,
        start: start_time,
        end: end_time,
        is_all_day: is_all_day
      }
    rescue Google::Apis::ClientError => e
      Rails.logger.error("Failed to fetch event: #{e.message}")
      redirect_to calendar_path, alert: "Failed to load event."
    end
  end

  private

  def calendar_service_or_unauthorized
    unless current_user.google_access_token.present?
      redirect_to login_google_path, alert: "Please log in with Google to continue."
      return nil
    end

    # Refresh the token if it's expired
    if current_user.google_token_expires_at.nil? || current_user.google_token_expires_at < Time.current
      client = Signet::OAuth2::Client.new(
        client_id:            ENV["GOOGLE_CLIENT_ID"],
        client_secret:        ENV["GOOGLE_CLIENT_SECRET"],
        refresh_token:        current_user.google_refresh_token,
        token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
      )

      begin
        client.refresh!

        current_user.update(
          google_access_token: client.access_token,
          # refresh_token may not be returned every time, so keep the old one if missing
          google_refresh_token: client.refresh_token || current_user.google_refresh_token,
          google_token_expires_at: Time.current + client.expires_in
        )
      rescue Signet::AuthorizationError => e
        Rails.logger.error("Token refresh failed: #{e.message}")
        reset_session
        redirect_to login_google_path, alert: "Authentication expired, please log in again."
        return nil
      end
    end

    # Use the (now fresh) token
    client = Signet::OAuth2::Client.new(
      client_id:            ENV["GOOGLE_CLIENT_ID"],
      client_secret:        ENV["GOOGLE_CLIENT_SECRET"],
      access_token:         current_user.google_access_token,
      token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
    )

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service
  end


  def parse_date(date)
    return date if date.is_a?(Date)
    Date.parse(date) rescue nil
  end
end
