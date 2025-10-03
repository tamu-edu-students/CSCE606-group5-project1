class AddLeetcodeUsernameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :leetcode_username, :string
  end
end
