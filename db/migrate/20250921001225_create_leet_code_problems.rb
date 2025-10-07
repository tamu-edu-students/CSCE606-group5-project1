# Creates master table of LeetCode problems with metadata for problem selection
class CreateLeetCodeProblems < ActiveRecord::Migration[8.0]
  def change
    create_table :leet_code_problems do |t|
      t.string :leetcode_id, null: false  # Official LeetCode problem ID
      t.string :title                     # Problem title (e.g., "Two Sum")
      t.string :difficulty                # Difficulty level (Easy/Medium/Hard)
      t.string :url                       # Direct link to LeetCode problem
      t.text :tags                        # Comma-separated topic tags
      t.timestamps
    end
    add_index :leet_code_problems, :leetcode_id, unique: true  # Prevent duplicate problems
  end
end
