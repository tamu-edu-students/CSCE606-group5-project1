require 'ostruct'

# This step now creates a Hash to be returned by the mock, matching the view's expectations.
Given('I have the following LeetCode stats for the last 7 days:') do |table|
  stats_data = table.hashes.first

  # Create a Hash, as the view uses @stats[:key] syntax
  stats_result = {
    weekly_solved_count: stats_data['Problems Solved This Week'].to_i,
    current_streak_days: stats_data['Current Streak'].to_i,
    total_solved_all_time: stats_data['Total Problems Solved'].to_i,
    highlight: "Great work on Medium problems!" # Optional highlight
  }

  # Mock the service object to return our Hash
  allow(Reports::WeeklyStats).to receive_message_chain(:new, :call).and_return(stats_result)
end

# This step mocks the "zero state" response.
Given('I have no LeetCode stats for the last 7 days') do
  stats_result = { weekly_solved_count: 0 }
  allow(Reports::WeeklyStats).to receive_message_chain(:new, :call).and_return(stats_result)
end

When('I navigate to my LeetCode stats page') do
  visit statistics_path
end

Then('I should see a {string} section') do |section_title|
  expect(page).to have_content(section_title)
end

# This is a new, more robust step. It finds the card by its title
# and then checks for the value within that specific card.
Then('I should see a stat card with title {string} and value {string}') do |title, value|
  # Find the specific stat card that contains the title
  card = find('.stat-card', text: title)

  # Within that card, expect to find the value
  within(card) do
    expect(page).to have_css('.stat-value', text: value)
  end
end

Then('I should see the message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should not see any stat cards') do
  expect(page).not_to have_css('.stat-card')
end
