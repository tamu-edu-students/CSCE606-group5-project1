# Creates users table for authentication and profile management
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :netid           # University NetID for TAMU authentication
      t.string :email           # Primary institutional email address
      t.string :first_name      # User's first name from OAuth
      t.string :last_name       # User's last name from OAuth
      t.string :role            # User role (student/admin)
      t.datetime :last_login_at # Track last login time for analytics

      t.timestamps
    end
  end
end
