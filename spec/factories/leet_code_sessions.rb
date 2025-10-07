FactoryBot.define do
  factory :leet_code_session do
    association :user
    scheduled_time { 1.day.from_now }
    duration_minutes { 60 }
    status { 'scheduled' }
    title { 'LeetCode Practice Session' }
    description { 'Practice session description' }
    google_event_id { nil }
  end
end
