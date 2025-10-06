# LeetCode problem model representing individual coding problems from LeetCode platform
# Stores problem metadata including difficulty level and relationships with user sessions
class LeetCodeProblem < ApplicationRecord
  # Define difficulty levels as enum with string values
  enum :difficulty, { Easy: "easy", Medium: "medium", Hard: "hard" }

  # Validation rules for required fields
  validates :leetcode_id, presence: true, uniqueness: true  # LeetCode problem ID must be present and unique
  validates :difficulty, presence: true                     # Difficulty level is required

  # Associations with other models
  has_many :leet_code_session_problems                                    # Join table for many-to-many relationship
  has_many :leet_code_sessions, through: :leet_code_session_problems     # Problems can be associated with multiple sessions

  # Override difficulty method to return humanized version
  def difficulty
    super.humanize  # Convert enum value to human-readable format (e.g., "easy" -> "Easy")
  end
end
