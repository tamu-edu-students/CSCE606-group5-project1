Given('I have a LeetCode username set') do
  @current_user.update(leetcode_username: 'testuser')
  # Mock API responses
  allow_any_instance_of(Leetcode::FetchStats).to receive(:solved).and_return(
    { total: 150, easy: 80, medium: 50, hard: 20 }
  )
  allow_any_instance_of(Leetcode::FetchStats).to receive(:calendar).and_return(
    { 'submissionCalendar' => { '1735689600' => 5, '1735776000' => 3 } }
  )
end

Given('I have no LeetCode username set') do
  @current_user.update(leetcode_username: nil)
end

When('I navigate to my LeetCode stats page') do
  visit statistics_path
end

Then('I should see the solved problems statistics') do
  expect(page).to have_content('Total Solved')
  expect(page).to have_content('150')
  expect(page).to have_content('Last 7 Days')
  expect(page).to have_content('Last 30 Days')
  expect(page).to have_content('Difficulty Breakdown')
  expect(page).to have_content('Easy')
  expect(page).to have_content('80')
  expect(page).to have_content('Medium')
  expect(page).to have_content('50')
  expect(page).to have_content('Hard')
  expect(page).to have_content('20')
end

Then("I should see zero statistics") do
  expect(page).to have_text("No LeetCode activity recorded. Solve a problem to see your stats!")
  expect(page).not_to have_text("Total Solved")
end
