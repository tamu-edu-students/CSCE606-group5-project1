# Creates events table for calendar integration (later dropped in favor of Google Calendar sync)
class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :summary                                   # Event title/description
      t.datetime :start_time                              # Event start time
      t.datetime :end_time                                # Event end time
      t.references :user, null: false, foreign_key: true # Event owner

      t.timestamps
    end
  end
end
