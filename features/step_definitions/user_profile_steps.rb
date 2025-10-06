When('I click on the user avatar') do
  avatar_link = find(".user-avatar-link", match: :first)
  execute_script("arguments[0].click();", avatar_link)
end

Then('I should be on the user profile page') do
  expect(page).to have_current_path(profile_path)
end

Then('I should see {string} in the navbar') do |text|
  within(".user-info", match: :first) do
    expect(page).to have_content(text)
  end
end

Given('the user {string} has leetcode_username {string}') do |netid, username|
  user = User.find_by(netid: netid)
  user.update!(leetcode_username: username)
end

When('I visit the user profile API endpoint') do
  visit api_current_user_path(format: :json)
end

When('a visitor visits the user profile API endpoint') do
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
    expect(page.body).to have_content("Not signed in")
  end
end

Then('the JSON response should contain an error message {string}') do |error_message|
  json_response = JSON.parse(page.body)
  expect(json_response['error']).to eq(error_message)
end
