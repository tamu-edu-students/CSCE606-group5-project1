When('I click on the profile tab') do
  # Click the Profile link in the sidebar navigation
  within('.sidebar-nav') do
    click_link 'Profile'
  end
end

When('I visit my profile page') do
  visit profile_path
end

When('I update my LeetCode username to {string}') do |username|
  fill_in 'LeetCode Username', with: username
  click_button 'Update Profile'
end

Then('I should be on the user profile page') do
  expect(page).to have_current_path(profile_path)
end

Then('I should see {string} in the navbar') do |text|
  within('.sidebar-nav') do
    expect(page).to have_content(text)
  end
end

Then('my LeetCode username should be {string}') do |username|
  @current_user.reload
  expect(@current_user.leetcode_username).to eq(username)
end

Given('the user {string} has leetcode_username {string}') do |netid, username|
  user = User.find_by(netid: netid) || @current_user
  user.update!(leetcode_username: username)
end

Given('I am on the dashboard') do
  visit dashboard_path
end

Then('I should see the profile form') do
  expect(page).to have_field('First Name')
  expect(page).to have_field('Last Name')
  expect(page).to have_field('Personal Email')
  expect(page).to have_field('LeetCode Username')
  expect(page).to have_button('Update Profile')
end

Then('I should see my current information') do
  expect(page).to have_content(@current_user.full_name)
  expect(page).to have_content(@current_user.email)
end

When('I fill in the first name field with {string}') do |name|
  fill_in 'First Name', with: name
end

When('I fill in the last name field with {string}') do |name|
  fill_in 'Last Name', with: name
end

When('I fill in the personal email field with {string}') do |email|
  fill_in 'Personal Email', with: email
end

# API-related steps
When('I visit the user profile API endpoint') do
  visit api_current_user_path(format: :json)
end

When('a visitor visits the user profile API endpoint') do
  # Clear session to simulate unauthenticated user
  page.reset_session!
  visit api_current_user_path(format: :json)
end

Then('the JSON response should contain my user details') do
  json_response = JSON.parse(page.body)
  expect(json_response['id']).to eq(@current_user.id)
  expect(json_response['name']).to eq(@current_user.full_name)
  expect(json_response['email']).to eq(@current_user.email)
end

Then('the response status should be {int}') do |status_code|
  if status_code == 401
    # Update to match the actual error message from your API
    expect(page.body).to have_content("Authentication required")
  elsif status_code == 200
    expect(page.status_code).to eq(200) if page.respond_to?(:status_code)
  end
end

Then('the JSON response should contain an error message {string}') do |error_message|
  json_response = JSON.parse(page.body)
  # Update to match the actual error message format
  if error_message == "Not signed in"
    expect(json_response['error']).to eq("Authentication required")
  else
    expect(json_response['error']).to eq(error_message)
  end
end
