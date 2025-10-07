# Creates coding sessions table to track scheduled practice time
class CreateLeetCodeSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :leet_code_sessions do |t|
      t.references :user, null: false, foreign_key: true  # Session owner
      t.datetime :scheduled_time                          # When session is planned
      t.integer :duration_minutes                         # Session length in minutes
      t.string :status                                    # scheduled/completed/skipped
      t.timestamps
    end
  end
end
