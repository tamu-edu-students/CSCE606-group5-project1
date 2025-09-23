class LeetCodeSessionProblem < ApplicationRecord
  belongs_to :leet_code_session
  belongs_to :leet_code_problem

  validates :leet_code_session_id, presence: true
  validates :leet_code_problem_id, presence: true
end
