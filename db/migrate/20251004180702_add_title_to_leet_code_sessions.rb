class AddTitleToLeetCodeSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :leet_code_sessions, :title, :string
  end
end
