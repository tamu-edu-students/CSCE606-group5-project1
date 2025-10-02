require 'ostruct'

Given('I have solved the following LeetCode problems in the last {int} days:') do |_days, table|
  solved_problems_data = table.hashes

  easy_count = solved_problems_data.count { |p| p['Difficulty'] == 'Easy' }
  medium_count = solved_problems_data.count { |p| p['Difficulty'] == 'Medium' }
  hard_count = solved_problems_data.count { |p| p['Difficulty'] == 'Hard' }
  total_solved = solved_problems_data.length

  stats_result = OpenStruct.new(
    easy_count: easy_count,
    medium_count: medium_count,
    hard_count: hard_count,
    total_solved_this_week: total_solved
  )

  allow(Reports::WeeklyStats).to receive_message_chain(:new, :call).and_return(stats_result)
end

# Creates a single SolvedProblem record outside the primary time window.
Given('I also solved {string} (Easy) {int} days ago') do |title, days_ago|
  create(:solved_problem,
    user: @current_user,
    title: title,
    difficulty: 'Easy',
    solved_at: days_ago.days.ago
  )
end

Given('I have not solved any LeetCode problems in the last {int} days') do |_days|
  stats_result = OpenStruct.new(
    easy_count: 0,
    medium_count: 0,
    hard_count: 0,
    total_solved_this_week: 0
  )
  allow(Reports::WeeklyStats).to receive_message_chain(:new, :call).and_return(stats_result)
end

# Navigates to the page that displays the LeetCode stats.
When('I navigate to my LeetCode stats page') do
  visit statistics_path
end

# Checks for the presence of a section title and the calculated date range.
Then('I should see a {string} section for the period {string}') do |section_title, expected_date_range|
  expect(page).to have_content(section_title)
  expect(page).to have_content(expected_date_range) # e.g., "September 26, 2025 - October 2, 2025"
end

# A simpler check for just the section title.
Then('I should see a {string} section') do |section_title|
  expect(page).to have_content(section_title)
end

# A generic step to check for any text within a specific summary section.
Then('within the summary, I should see {string}') do |text|
  within('#weekly-summary') do
    expect(page).to have_content(text)
  end
end

Then('I should see a message like {string}') do |message|
  expect(page).to have_content(message)
end

# Verifies the breakdown of solved problems by difficulty.
Then('the summary should show the following breakdown:') do |table|
  within('#weekly-summary-breakdown') do
    table.hashes.each do |row|
      expected_text = "#{row['Difficulty']}: #{row['Count']}"
      expect(page).to have_content(expected_text)
    end
  end
end

# Checks for the *absence* of content, confirming the breakdown section isn't rendered.
Then('I should not see a difficulty breakdown') do
  expect(page).not_to have_css('#weekly-summary-breakdown')
  expect(page).not_to have_content('Easy:')
  expect(page).not_to have_content('Medium:')
  expect(page).not_to have_content('Hard:')
end