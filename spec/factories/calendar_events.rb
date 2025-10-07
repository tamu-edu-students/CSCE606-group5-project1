FactoryBot.define do
  factory :calendar_event do
    association :user
    sequence(:title) { |n| "Calendar Event #{n}" }
    description { "Event description" }
    start_time { 1.day.from_now }
    end_time { 1.day.from_now + 1.hour }
    event_type { 'meeting' }
    all_day { false }
    google_event_id { nil }
  end
end
