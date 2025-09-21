class CreateLeetCodeProblems < ActiveRecord::Migration[8.0]
  def change
    create_table :leet_code_problems do |t|
      t.string :leetcode_id, null: false
      t.string :title
      t.string :difficulty
      t.string :url
      t.text :tags
      t.timestamps
    end
    add_index :leet_code_problems, :leetcode_id, unique: true
  end
end
