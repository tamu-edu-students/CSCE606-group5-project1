# Adds personal email field for weekly report delivery outside institutional email
class AddPersonalEmailToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :personal_email, :string  # Personal email for weekly progress reports
  end
end
