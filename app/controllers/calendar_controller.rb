require "google/apis/calendar_v3"
require "googleauth"

class CalendarController < ApplicationController
  before_action :authenticate_user!

  def show
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.today

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
      token_credential_uri: "https://accounts.google.com/o/oauth2/token",
      expires_at: session[:google_token_expires_at]
    )

    begin
      if client.expired?
        client.refresh!
        session[:google_token] = client.access_token
        session[:google_refresh_token] ||= client.refresh_token
        session[:google_token_expires_at] = client.expires_at
      end
    rescue Signet::AuthorizationError => e
      Rails.logger.error("Token refresh faile          d: #{e.message}")
      flash.now[:alert] = "Authentication expired. Please log in again."
      @events = []
      return
    end

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

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

  def sync
    result = GoogleCalendarSync.sync_for_user(current_user, session)

    if result[:success]
      flash[:notice] = "Calendar synced successfully! " \
                       "#{result[:synced]} created, " \
                       "#{result[:updated]} updated, " \
                       "#{result[:deleted]} deleted."

      # Log the sync
      Rails.logger.info("Calendar sync for user #{current_user.id}: #{result}")
    else
      flash[:alert] = "Sync failed: #{result[:error]}"
    end

    redirect_back(fallback_location: calendar_path)
  end

  # Background job version (optional but recommended)
  def sync_async
    GoogleCalendarSyncJob.perform_later(current_user.id, session_data)

    flash[:notice] = "Calendar sync started in background. You'll be notified when complete."
    redirect_back(fallback_location: calendar_path)
  end

  private

  def session_data
    {
      "google_token" => session[:google_token],
      "google_refresh_token" => session[:google_refresh_token],
      "google_token_expires_at" => session[:google_token_expires_at]
    }
  end
end
