# Required Google APIs for calendar integration
require "google/apis/calendar_v3"
require "googleauth"

# Controller for Google Calendar integration and management
# Handles calendar viewing, event synchronization, and OAuth token management
class CalendarController < ApplicationController
  # Ensure user is authenticated before accessing calendar features
  before_action :authenticate_user!

  # GET /calendar
  # Display calendar view with events for the specified month
  def show
    # Parse date parameter or default to today
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.today

    # Get authenticated Google Calendar service or redirect if unauthorized
    service = calendar_service_or_unauthorized
    unless service
      flash.now[:alert] = "Not authenticated with Google. Please log in."
      @events = []
      return
    end

    # Define time range for fetching events (entire month)
    start_time = @current_date.beginning_of_month.beginning_of_day.utc.iso8601
    end_time   = @current_date.end_of_month.end_of_day.utc.iso8601

    begin
      # Fetch events from Google Calendar API
      response = service.list_events("primary", single_events: true, order_by: "startTime", time_min: start_time, time_max: end_time)

      # Transform Google Calendar events into our application format
      @events = response.items.map do |event|
        # Determine if event is all-day (no specific time)
        is_all_day = event.start.date_time.nil?
        
        if is_all_day
          # All-day events use date only
          start_date = parse_date(event.start.date)
          end_date   = parse_date(event.end.date)
        else
          # Timed events use datetime
          start_date = event.start.date_time
          end_date   = event.end.date_time
        end

        # Return standardized event hash
        {
          id: event.id,
          summary: event.summary,
          start: start_date,
          end: end_date,
          is_all_day: is_all_day
        }
      end
    rescue => e
      # Handle API errors gracefully
      Rails.logger.error("Calendar error: #{e.message}")
      flash.now[:alert] = "Failed to load calendar events."
      @events = []
    end
  end

  # POST /calendar/sync
  # Synchronize local LeetCode sessions with Google Calendar events
  def sync
    # Use GoogleCalendarSync service to perform synchronization
    result = GoogleCalendarSync.sync_for_user(current_user, session)

    if result[:success]
      # Display success message with sync statistics
      flash[:notice] = "Calendar synced successfully! " \
                       "#{result[:synced]} created, " \
                       "#{result[:updated]} updated, " \
                       "#{result[:deleted]} deleted."
      Rails.logger.info("Calendar sync for user #{current_user.id}: #{result}")
    else
      # Display error message if sync failed
      flash[:alert] = "Sync failed: #{result[:error]}"
    end

    # Redirect back to previous page or calendar as fallback
    redirect_back(fallback_location: calendar_path)
  end

  # GET /calendar/new
  # Display form for creating a new calendar event
  def new
    @event = Google::Apis::CalendarV3::Event.new
  end

  # GET /calendar/:id/edit
  # Display form for editing an existing calendar event
  def edit
    # Get authenticated service or return early if unauthorized
    service = calendar_service_or_unauthorized or return

    begin
      # Fetch event details from Google Calendar
      event = service.get_event("primary", params[:id])
      is_all_day = event.start.date_time.nil?

      # Parse start time based on event type
      start_time = if is_all_day
               DateTime.parse("#{event.start.date} 00:00")  # All-day event
      else
               event.start.date_time                        # Timed event
      end

      # Parse end time based on event type
      end_time = if is_all_day
             DateTime.parse("#{event.end.date} 00:00")      # All-day event
      else
             event.end.date_time                            # Timed event
      end

      # Create event hash for form display
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
      # Handle API errors when fetching event
      Rails.logger.error("Failed to fetch event: #{e.message}")
      redirect_to calendar_path, alert: "Failed to load event."
    end
  end

  private

  # Get authenticated Google Calendar service or handle authorization
  # Returns nil and redirects if user is not properly authenticated
  def calendar_service_or_unauthorized
    # Check if user has Google access token
    unless current_user.google_access_token.present?
      redirect_to login_google_path, alert: "Please log in with Google to continue."
      return nil
    end

    # Refresh the token if it's expired
    if current_user.google_token_expires_at.nil? || current_user.google_token_expires_at < Time.current
      # Set up OAuth2 client for token refresh
      client = Signet::OAuth2::Client.new(
        client_id:            ENV["GOOGLE_CLIENT_ID"],
        client_secret:        ENV["GOOGLE_CLIENT_SECRET"],
        refresh_token:        current_user.google_refresh_token,
        token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
      )

      begin
        # Attempt to refresh the access token
        client.refresh!

        # Update user with new token information
        current_user.update(
          google_access_token: client.access_token,
          # refresh_token may not be returned every time, so keep the old one if missing
          google_refresh_token: client.refresh_token || current_user.google_refresh_token,
          google_token_expires_at: Time.current + client.expires_in
        )
      rescue Signet::AuthorizationError => e
        # Handle token refresh failure
        Rails.logger.error("Token refresh failed: #{e.message}")
        reset_session
        redirect_to login_google_path, alert: "Authentication expired, please log in again."
        return nil
      end
    end

    # Use the (now fresh) token to create authenticated client
    client = Signet::OAuth2::Client.new(
      client_id:            ENV["GOOGLE_CLIENT_ID"],
      client_secret:        ENV["GOOGLE_CLIENT_SECRET"],
      access_token:         current_user.google_access_token,
      token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
    )

    # Create and configure Google Calendar service
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service
  end

  # Helper method to safely parse date strings
  # Returns the date if already a Date object, otherwise attempts to parse
  def parse_date(date)
    return date if date.is_a?(Date)
    Date.parse(date) rescue nil
  end
end
