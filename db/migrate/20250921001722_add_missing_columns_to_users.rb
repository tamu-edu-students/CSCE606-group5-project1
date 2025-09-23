class AddMissingColumnsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_streak, :integer
    add_column :users, :longest_streak, :integer
    add_column :users, :preferred_topics, :text
  end
end
