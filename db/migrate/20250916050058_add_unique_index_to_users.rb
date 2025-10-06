# Adds unique constraints to prevent duplicate user accounts
class AddUniqueIndexToUsers < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :email, unique: true  # Ensure one account per email address
    add_index :users, :netid, unique: true  # Ensure one account per NetID
  end
end
