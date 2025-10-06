# Adds user progress tracking and preference columns
class AddMissingColumnsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_streak, :integer    # Current consecutive days solving problems
    add_column :users, :longest_streak, :integer    # Historical longest streak record
    add_column :users, :preferred_topics, :text     # User's preferred problem categories
  end
end
