FactoryBot.define do
  factory :solved_problem do
    association :user

    title { "Default Problem Title" }
    difficulty { "Easy" }
    solved_at { Time.current }
  end
end