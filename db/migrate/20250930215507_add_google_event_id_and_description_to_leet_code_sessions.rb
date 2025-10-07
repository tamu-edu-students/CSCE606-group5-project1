# Links LeetCode sessions with Google Calendar events for synchronization
class AddGoogleEventIdAndDescriptionToLeetCodeSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :leet_code_sessions, :google_event_id, :string  # Google Calendar event ID for sync
    add_column :leet_code_sessions, :description, :text       # Session description/notes
  end
end
