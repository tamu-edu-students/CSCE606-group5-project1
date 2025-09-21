class LeetCodeSession < ApplicationRecord
  enum :status, { scheduled: 'scheduled', completed: 'completed', skipped: 'skipped' }

  belongs_to :user
  has_many :leet_code_session_problems, dependent: :destroy
  has_many :leet_code_problems, through: :leet_code_session_problems

  validates :user_id, presence: true
end
