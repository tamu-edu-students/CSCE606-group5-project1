class LeetCodeEntry < ApplicationRecord
  enum :difficulty, { easy: 0, medium: 1, hard: 2 }

  validates :problem_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :difficulty, presence: true

  scope :today, -> { where(solved_on: Date.current) }
  scope :recent_first, -> { order(solved_on: :desc, created_at: :desc) }

  def self.fetch_problem_details(problem_number)
    response = HTTParty.get("https://leetcode-api-pied.vercel.app/problem/#{problem_number}")
    if response.success?
      data = response.parsed_response
      {
        title: data["title"],
        difficulty: data["difficulty"].downcase
      }
    else
      nil
    end
  rescue
    nil
  end
end
