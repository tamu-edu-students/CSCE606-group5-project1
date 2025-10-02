Given('I am logged in as {string}') do |netid|
  user = User.find_by(netid: netid)
  visit dashboard_path
  page.driver.request.env['rack.session']['user_id'] = user.id
end

When('I click on the user avatar') do
  find("#userAvatar").click
end

Then('I should be on the user profile page') do
  expect(page).to have_current_path(profile_path)
end

Then('I should see {string} in the navbar') do |text|
  within(".user-info") do
    expect(page).to have_content(text)
  end
end

Given('the user {string} has leetcode_username {string}') do |netid, username|
  user = User.find_by(netid: netid)
  user.update!(leetcode_username: username)
end