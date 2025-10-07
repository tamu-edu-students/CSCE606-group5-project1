FactoryBot.define do
  factory :user do
    sequence(:netid) { |n| "testuser#{n}" }
    sequence(:email) { |n| "testuser#{n}@tamu.edu" }

    first_name { "Test" }
    last_name  { "User" }
    leetcode_username { nil }

    google_access_token { "test_access_token" }
    google_refresh_token { "test_refresh_token" }
    google_token_expires_at { Time.current + 1.hour }
  end
end
