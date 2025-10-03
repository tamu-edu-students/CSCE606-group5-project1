class AddGoogleEventIdAndDescriptionToLeetCodeSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :leet_code_sessions, :google_event_id, :string
    add_column :leet_code_sessions, :description, :text
  end
end
