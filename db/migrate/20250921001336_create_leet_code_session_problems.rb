# Creates join table linking sessions with specific problems and tracking completion
class CreateLeetCodeSessionProblems < ActiveRecord::Migration[8.0]
  def change
    create_table :leet_code_session_problems do |t|
      t.references :leet_code_session, null: false, foreign_key: true  # Which session
      t.references :leet_code_problem, null: false, foreign_key: true  # Which problem
      t.boolean :solved, default: false                               # Completion status
      t.datetime :solved_at                                           # When problem was completed
      t.timestamps
    end
  end
end
