class CreateLeetCodeSessionProblems < ActiveRecord::Migration[8.0]
  def change
    create_table :leet_code_session_problems do |t|
      t.references :leet_code_session, null: false, foreign_key: true
      t.references :leet_code_problem, null: false, foreign_key: true
      t.boolean :solved, default: false
      t.datetime :solved_at
      t.timestamps
    end
  end
end
