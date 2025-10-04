class LeetCodeProblem < ApplicationRecord
  enum :difficulty, { Easy: "easy", Medium: "medium", Hard: "hard" }

  validates :leetcode_id, presence: true, uniqueness: true
  validates :difficulty, presence: true

  has_many :leet_code_session_problems
  has_many :leet_code_sessions, through: :leet_code_session_problems
end
