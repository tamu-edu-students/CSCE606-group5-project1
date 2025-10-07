# Adds LeetCode username field for API integration and stats fetching
class AddLeetcodeUsernameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :leetcode_username, :string  # User's LeetCode profile username
  end
end
