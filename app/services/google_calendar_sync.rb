# Service class for synchronizing Google Calendar events with LeetCode sessions
# Handles bidirectional sync between Google Calendar and local LeetCode session records
class GoogleCalendarSync
  # Initialize sync service for a specific user
  # @param user [User] The user whose calendar will be synchronized
  def initialize(user)
    @user = user
    @session = {}
  end

  # Class method to create instance and perform sync in one call
  # @param user [User] The user to sync calendar for
  # @param session [Hash] Session data containing Google OAuth tokens
  # @return [Hash] Sync results with success status and statistics
  def self.sync_for_user(user, session)
    new(user).sync(session)
  end

  # Main synchronization method
  # @param session [Hash] Session data containing Google OAuth tokens
  # @return [Hash] Results hash with success status and sync statistics
  def sync(session)
    @session = session

    # Build OAuth client for Google API authentication
    client = build_oauth_client
    return { success: false, error: "Not authenticated" } unless client

    # Refresh token if expired to maintain API access
    unless refresh_token_if_needed(client)
      return { success: false, error: "Authentication expired" }
    end

    # Create Google Calendar service with authenticated client
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    # Define sync time range: 30 days in the past to 90 days in the future
    start_time = 30.days.ago.beginning_of_day.utc.iso8601
    end_time = 90.days.from_now.end_of_day.utc.iso8601

    begin
      # Fetch events from Google Calendar within the specified time range
      response = service.list_events(
        "primary",                # Use primary calendar
        single_events: true,      # Expand recurring events
        order_by: "startTime",    # Sort by start time
        time_min: start_time,     # Earliest event time
        time_max: end_time        # Latest event time
      )

      # Process the fetched events and sync with local database
      sync_results = process_events(response.items)

      # Return success with detailed statistics
      {
        success: true,
        synced: sync_results[:synced],    # New events created
        updated: sync_results[:updated],  # Existing events updated
        skipped: sync_results[:skipped],  # Events unchanged
        deleted: sync_results[:deleted]   # Local events removed
      }
    rescue Google::Apis::Error => e
      # Handle Google API specific errors
      Rails.logger.error("Google Calendar API error: #{e.message}")
      { success: false, error: "Failed to fetch calendar events" }
    rescue StandardError => e
      # Handle any other errors during sync
      Rails.logger.error("Calendar sync error: #{e.message}")
      { success: false, error: e.message }
    end
  end

  private

  # Build OAuth2 client for Google API authentication
  # @return [Signet::OAuth2::Client, nil] Authenticated client or nil if no token
  def build_oauth_client
    return nil unless @session[:google_token]

    Signet::OAuth2::Client.new(
      access_token: @session[:google_token],
      refresh_token: @session[:google_refresh_token],
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      token_credential_uri: ENV["GOOGLE_OAUTH_URI"],
      expires_at: @session[:google_token_expires_at]
    )
  end

  # Refresh OAuth token if it has expired
  # @param client [Signet::OAuth2::Client] The OAuth client to refresh
  # @return [Boolean] True if refresh successful or not needed, false if failed
  def refresh_token_if_needed(client)
    return true unless client.expired?

    begin
      # Attempt to refresh the access token
      client.refresh!

      # Update session with new token information
      @session[:google_token] = client.access_token
      @session[:google_refresh_token] ||= client.refresh_token  # Keep existing if not returned
      @session[:google_token_expires_at] = client.expires_at
      true
    rescue Signet::AuthorizationError => e
      # Log error and return false if refresh fails
      Rails.logger.error("Token refresh failed: #{e.message}")
      false
    end
  end

  # Process array of Google Calendar events and sync with local database
  # @param google_events [Array] Array of Google Calendar event objects
  # @return [Hash] Statistics about sync operations performed
  def process_events(google_events)
    synced = 0   # Count of new events created
    updated = 0  # Count of existing events updated
    skipped = 0  # Count of events that didn't need changes

    # Extract event IDs for cleanup of deleted events
    google_event_ids = google_events.map(&:id).compact

    # Process each event from Google Calendar
    google_events.each do |event|
      next if event.status == "cancelled"  # Skip cancelled events

      # Skip all-day events or events without proper time information
      next if event.start.date_time.nil?

      # Sync individual event and track result
      result = sync_event(event)
      case result
      when :created
        synced += 1
      when :updated
        updated += 1
      when :skipped
        skipped += 1
      end
    end

    # Clean up local events that no longer exist in Google Calendar
    deleted = delete_removed_events(google_event_ids)

    { synced: synced, updated: updated, skipped: skipped, deleted: deleted }
  end

  # Sync a single Google Calendar event with local LeetCode session
  # @param event [Google::Apis::CalendarV3::Event] Google Calendar event object
  # @return [Symbol] Result of sync operation (:created, :updated, or :skipped)
  def sync_event(event)
    start_time = event.start.date_time
    end_time = event.end.date_time
    duration = calculate_duration(start_time, end_time)

    # Find existing session or create new one based on Google event ID
    session = LeetCodeSession.find_or_initialize_by(
      user_id: @user.id,
      google_event_id: event.id
    )

    # Extract event information with fallbacks
    title = event.summary.presence || "Untitled Session"
    description = event.description.presence || title

    # Check if any session attributes have changed
    changed = session.new_record? ||
              session.scheduled_time != start_time ||
              session.duration_minutes != duration ||
              session.title != title ||
              session.description != description

    if changed
      # Update session attributes and save
      session.assign_attributes(
        scheduled_time: start_time,
        duration_minutes: duration,
        title: title,
        description: description,
        status: determine_status(start_time, end_time)
      )
      session.save!

      # Return appropriate result based on whether this was a new record
      session.previously_new_record? ? :created : :updated
    else
      :skipped  # No changes needed
    end

  rescue StandardError => e
    # Log error and skip this event if sync fails
    Rails.logger.error("Failed to sync event #{event.id}: #{e.message}")
    :skipped
  end

  # Calculate event duration in minutes from start and end times
  # @param start_time [DateTime] Event start time
  # @param end_time [DateTime] Event end time
  # @return [Integer] Duration in minutes (minimum 1 minute)
  def calculate_duration(start_time, end_time)
    # Ensure we have Time objects for calculation
    start_time = start_time.to_time if start_time.respond_to?(:to_time)
    end_time = end_time.to_time if end_time.respond_to?(:to_time)

    # Calculate duration in seconds and convert to minutes
    duration_seconds = end_time - start_time
    duration_minutes = (duration_seconds / 60).to_i

    # Ensure minimum duration of 1 minute for positive durations
    duration_minutes = 1 if duration_seconds > 0 && duration_minutes == 0

    duration_minutes
  end

  # Determine session status based on current time and event timing
  # @param start_time [DateTime] Event start time
  # @param end_time [DateTime] Event end time
  # @return [String] Status ("completed" or "scheduled")
  def determine_status(start_time, end_time)
    now = Time.current
    if end_time < now
      "completed"  # Event has already ended
    else
      "scheduled"  # Event is in the future or currently ongoing
    end
  end

  # Delete local LeetCode sessions that no longer exist in Google Calendar
  # @param google_event_ids [Array<String>] Array of current Google Calendar event IDs
  # @return [Integer] Number of local sessions deleted
  def delete_removed_events(google_event_ids)
    # Find sessions that have Google event IDs but are not in current event list
    deleted_sessions = LeetCodeSession
      .where(user_id: @user.id)                    # Only this user's sessions
      .where.not(google_event_id: nil)             # Only sessions with Google event IDs
      .where.not(google_event_id: google_event_ids) # Not in current Google events

    # Delete the sessions and return count
    deleted_count = deleted_sessions.destroy_all.size
    deleted_count
  end
end
