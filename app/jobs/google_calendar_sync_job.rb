class GoogleCalendarSyncJob < ApplicationJob
  queue_as :default

  def perform(user_id, session_data)
    user = User.find(user_id)

    mock_session = {
      google_token: session_data["google_token"],
      google_refresh_token: session_data["google_refresh_token"],
      google_token_expires_at: session_data["google_token_expires_at"]
    }

    result = GoogleCalendarSync.sync_for_user(user, mock_session)

    if result[:success]
      Rails.logger.info("Background sync completed for user #{user_id}: #{result}")
    else
      Rails.logger.error("Background sync failed for user #{user_id}: #{result[:error]}")
    end
  end
end
