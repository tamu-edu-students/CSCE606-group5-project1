# Adds user account status tracking for enabling/disabling accounts
class AddActiveToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :active, :boolean, default: true  # Account active status (default enabled)
    add_index :users, :active                            # Index for filtering active users
  end
end
