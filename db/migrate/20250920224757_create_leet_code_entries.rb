# Creates table for tracking individual LeetCode problem completions (later replaced by sessions model)
class CreateLeetCodeEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :leet_code_entries do |t|
      t.integer :problem_number, null: false  # LeetCode problem number identifier
      t.string  :problem_title                 # Human-readable problem title
      t.integer :difficulty,   null: false    # Difficulty level (1=Easy, 2=Medium, 3=Hard)
      t.date    :solved_on,    null: false, default: -> { 'CURRENT_DATE' }  # Date problem was solved

      t.timestamps
    end
    add_index :leet_code_entries, :solved_on      # Index for date-based queries
    add_index :leet_code_entries, :problem_number # Index for problem lookups
  end
end
