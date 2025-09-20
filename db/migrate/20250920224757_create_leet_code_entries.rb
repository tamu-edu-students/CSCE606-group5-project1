class CreateLeetCodeEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :leet_code_entries do |t|
      t.string  :problem_name, null: false
      t.integer :difficulty,   null: false
      t.date    :solved_on,    null: false, default: -> { 'CURRENT_DATE' }

      t.timestamps
    end
    add_index :leet_code_entries, :solved_on
    add_index :leet_code_entries, :problem_name
  end
end
