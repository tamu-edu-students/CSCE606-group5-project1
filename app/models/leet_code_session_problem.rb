# Join table model connecting LeetCode sessions with specific problems
# Represents the many-to-many relationship between sessions and problems
class LeetCodeSessionProblem < ApplicationRecord
  # Associations - this model serves as a join table
  belongs_to :leet_code_session   # Reference to the coding session
  belongs_to :leet_code_problem   # Reference to the specific problem

  # Validation rules to ensure referential integrity
  validates :leet_code_session_id, presence: true   # Session ID is required
  validates :leet_code_problem_id, presence: true   # Problem ID is required
end
