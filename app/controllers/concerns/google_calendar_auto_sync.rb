# Controller concern for automatic Google Calendar synchronization
# Provides functionality to automatically sync calendar events after user login
# This concern can be included in controllers that handle user authentication
module GoogleCalendarAutoSync
  extend ActiveSupport::Concern

  # Hook that runs when this concern is included in a controller
  included do
    # Automatically sync calendar after successful login (create action)
    # Only runs if user is signed in after the action completes
    after_action :sync_calendar_on_login, only: [ :create ], if: :user_signed_in?
  end

  private

  # Trigger calendar synchronization after user login
  # Uses background job to avoid blocking the login process
  def sync_calendar_on_login
    # Only sync if Google token is present and hasn't been synced recently
    return unless session[:google_token]  # Skip if no Google authentication
    return if recently_synced?            # Skip if synced recently to avoid excessive API calls

    # Perform async sync to avoid blocking login response
    # Pass user ID and session data to background job
    GoogleCalendarSyncJob.perform_later(current_user.id, session_data_for_sync)

    # Mark last sync time to prevent frequent syncing
    session[:last_calendar_sync] = Time.current.to_i
  end

  # Check if calendar was synced recently to avoid excessive API calls
  # @return [Boolean] True if synced within the last 5 minutes
  def recently_synced?
    last_sync = session[:last_calendar_sync]
    return false unless last_sync  # No previous sync recorded

    # Don't sync if synced within last 5 minutes (300 seconds)
    Time.current.to_i - last_sync < 300
  end

  # Extract Google OAuth session data for background job
  # @return [Hash] Hash containing Google OAuth tokens and expiration
  def session_data_for_sync
    {
      "google_token" => session[:google_token],                    # Access token for Google API
      "google_refresh_token" => session[:google_refresh_token],    # Refresh token for token renewal
      "google_token_expires_at" => session[:google_token_expires_at] # Token expiration timestamp
    }
  end
end
