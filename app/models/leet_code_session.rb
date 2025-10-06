# LeetCode session model representing a coding practice session for a user
# Tracks session status and associates problems with users through sessions
class LeetCodeSession < ApplicationRecord
  # Define session status as enum with string values
  enum :status, { scheduled: "scheduled", completed: "completed", skipped: "skipped" }

  # Associations with other models
  belongs_to :user                                                        # Each session belongs to a specific user
  has_many :leet_code_session_problems, dependent: :destroy              # Join table records, destroy when session is deleted
  has_many :leet_code_problems, through: :leet_code_session_problems     # Many-to-many relationship with problems

  # Validation rules
  validates :user_id, presence: true                                      # User ID is required for each session
  validates :google_event_id, uniqueness: { scope: :user_id }, allow_nil: true  # Google event ID must be unique per user (optional)
end
