# Adds title field to sessions for better identification and display
class AddTitleToLeetCodeSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :leet_code_sessions, :title, :string  # Human-readable session title
  end
end
