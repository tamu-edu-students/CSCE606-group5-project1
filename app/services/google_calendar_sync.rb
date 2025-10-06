class GoogleCalendarSync
  def initialize(user)
    @user = user
    @session = {}
  end

  def self.sync_for_user(user, session)
    new(user).sync(session)
  end

  def sync(session)
    @session = session

    client = build_oauth_client
    return { success: false, error: "Not authenticated" } unless client

    # Refresh token if expired
    unless refresh_token_if_needed(client)
      return { success: false, error: "Authentication expired" }
    end

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    # Sync events from the last 30 days and next 90 days
    start_time = 30.days.ago.beginning_of_day.utc.iso8601
    end_time = 90.days.from_now.end_of_day.utc.iso8601

    begin
      response = service.list_events(
        "primary",
        single_events: true,
        order_by: "startTime",
        time_min: start_time,
        time_max: end_time
      )

      sync_results = process_events(response.items)

      {
        success: true,
        synced: sync_results[:synced],
        updated: sync_results[:updated],
        skipped: sync_results[:skipped],
        deleted: sync_results[:deleted]
      }
    rescue Google::Apis::Error => e
      Rails.logger.error("Google Calendar API error: #{e.message}")
      { success: false, error: "Failed to fetch calendar events" }
    rescue StandardError => e
      Rails.logger.error("Calendar sync error: #{e.message}")
      { success: false, error: e.message }
    end
  end

  private

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

  def refresh_token_if_needed(client)
    return true unless client.expired?

    begin
      client.refresh!
      @session[:google_token] = client.access_token
      @session[:google_refresh_token] ||= client.refresh_token
      @session[:google_token_expires_at] = client.expires_at
      true
    rescue Signet::AuthorizationError => e
      Rails.logger.error("Token refresh failed: #{e.message}")
      false
    end
  end

  def process_events(google_events)
    synced = 0
    updated = 0
    skipped = 0

    google_event_ids = google_events.map(&:id).compact

    google_events.each do |event|
      next if event.status == "cancelled"

      # Skip all-day events or events without proper time
      next if event.start.date_time.nil?

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

    # Delete local events that no longer exist in Google Calendar
    deleted = delete_removed_events(google_event_ids)

    { synced: synced, updated: updated, skipped: skipped, deleted: deleted }
  end

  def sync_event(event)
    start_time = event.start.date_time
    end_time = event.end.date_time
    duration = calculate_duration(start_time, end_time)

    # Find or initialize the session by google_event_id and user_id
    session = LeetCodeSession.find_or_initialize_by(
      user_id: @user.id,
      google_event_id: event.id
    )

    # Use event.summary as the title, fallback to "Untitled Session"
    title = event.summary.presence || "Untitled Session"
    description = event.description.presence || title

    # Check if anything changed
    changed = session.new_record? ||
              session.scheduled_time != start_time ||
              session.duration_minutes != duration ||
              session.title != title ||
              session.description != description

    if changed
      session.assign_attributes(
        scheduled_time: start_time,
        duration_minutes: duration,
        title: title,
        description: description,
        status: determine_status(start_time, end_time)
      )
      session.save!
      session.previously_new_record? ? :created : :updated
    else
      :skipped
    end

  rescue StandardError => e
    Rails.logger.error("Failed to sync event #{event.id}: #{e.message}")
    :skipped
  end


  def calculate_duration(start_time, end_time)
    start_time = start_time.to_time if start_time.respond_to?(:to_time)
    end_time = end_time.to_time if end_time.respond_to?(:to_time)

    duration_seconds = end_time - start_time
    duration_minutes = (duration_seconds / 60).to_i

    # In case duration less than 1 minute but positive, force it to 1 minute
    duration_minutes = 1 if duration_seconds > 0 && duration_minutes == 0

    duration_minutes
  end


  def determine_status(start_time, end_time)
    now = Time.current
    if end_time < now
      "completed"
    else
      "scheduled"
    end
  end

  def delete_removed_events(google_event_ids)
    # Delete sessions that no longer exist in Google Calendar
    deleted_sessions = LeetCodeSession
      .where(user_id: @user.id)
      .where.not(google_event_id: nil)
      .where.not(google_event_id: google_event_ids)
    deleted_count = deleted_sessions.destroy_all.size
    deleted_count
  end

end
