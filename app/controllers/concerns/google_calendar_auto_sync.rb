module GoogleCalendarAutoSync
  extend ActiveSupport::Concern

  included do
    after_action :sync_calendar_on_login, only: [ :create ], if: :user_signed_in?
  end

  private

  def sync_calendar_on_login
    # Only sync if Google token is present and hasn't been synced recently
    return unless session[:google_token]
    return if recently_synced?

    # Perform async sync to avoid blocking login
    GoogleCalendarSyncJob.perform_later(current_user.id, session_data_for_sync)

    # Mark last sync time
    session[:last_calendar_sync] = Time.current.to_i
  end

  def recently_synced?
    last_sync = session[:last_calendar_sync]
    return false unless last_sync

    # Don't sync if synced within last 5 minutes
    Time.current.to_i - last_sync < 300
  end

  def session_data_for_sync
    {
      "google_token" => session[:google_token],
      "google_refresh_token" => session[:google_refresh_token],
      "google_token_expires_at" => session[:google_token_expires_at]
    }
  end
end
