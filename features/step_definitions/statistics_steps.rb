Given('I have a LeetCode username set') do
  @current_user.update(leetcode_username: 'testuser')
end

Given('I have no LeetCode username set') do
  @current_user.update(leetcode_username: nil)
end

When('I navigate to my LeetCode stats page') do
  visit statistics_path
end

Then('I should see the solved problems statistics') do
  expect(page).to have_text("Problems Solved This Week")
  expect(page).to have_text("Total Problems Solved")
  expect(page).to have_text("Current Streak")
end

Then('I should see zero statistics') do
  expect(page).to have_content('Problems Solved')
  expect(page).to have_content('0')
  expect(page).to have_content('Current Streak')
  expect(page).to have_content('0 days')
end
