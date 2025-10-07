FactoryBot.define do
  factory :leet_code_problem do
    sequence(:title) { |n| "LeetCode Problem #{n}" }
    difficulty { "Easy" }
    tags { "array" }
    description { "Sample description" }
    sequence(:leetcode_id) { |n| n }
  end
end