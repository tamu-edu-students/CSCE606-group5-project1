# Background job for synchronizing Google Calendar events with LeetCode sessions
# Runs asynchronously to avoid blocking user requests during calendar sync operations
class GoogleCalendarSyncJob < ApplicationJob
  # Use the default queue for processing this job
  queue_as :default

  # Main job execution method
  # @param user_id [Integer] ID of the user to sync calendar for
  # @param session_data [Hash] Session data containing Google OAuth tokens
  def perform(user_id, session_data)
    # Find the user by ID
    user = User.find(user_id)

    # Create a mock session hash with Google OAuth tokens
    # This simulates the session object that the sync service expects
    mock_session = {
      google_token: session_data["google_token"],                    # Access token for Google API
      google_refresh_token: session_data["google_refresh_token"],    # Refresh token for token renewal
      google_token_expires_at: session_data["google_token_expires_at"] # Token expiration timestamp
    }

    # Perform the actual calendar synchronization using the service
    result = GoogleCalendarSync.sync_for_user(user, mock_session)

    # Log the result of the synchronization operation
    if result[:success]
      Rails.logger.info("Background sync completed for user #{user_id}: #{result}")
    else
      Rails.logger.error("Background sync failed for user #{user_id}: #{result[:error]}")
    end
  end
end
