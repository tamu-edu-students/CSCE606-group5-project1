class LeetCodeSession < ApplicationRecord
  enum :status, { scheduled: "scheduled", completed: "completed", skipped: "skipped" }

  belongs_to :user
  has_many :leet_code_session_problems, dependent: :destroy
  has_many :leet_code_problems, through: :leet_code_session_problems

  validates :user_id, presence: true
  validates :google_event_id, uniqueness: { scope: :user_id }, allow_nil: true
end
