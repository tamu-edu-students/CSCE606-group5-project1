class LeetCodeEntry < ApplicationRecord
  enum :difficulty, { easy: 0, medium: 1, hard: 2 }

  validates :problem_name, presence: true
  validates :difficulty, presence: true

  scope :today, -> { where(solved_on: Date.current) }
  scope :recent_first, -> { order(solved_on: :desc, created_at: :desc) }
end
