class CreateLeetCodeSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :leet_code_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :scheduled_time
      t.integer :duration_minutes
      t.string :status
      t.timestamps
    end
  end
end
