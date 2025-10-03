Given('I am logged in as {string}') do |netid|
  user = User.find_by(netid: netid)
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '123545',
    info: {
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name
    },
    credentials: {
      token: 'mock_token',
      refresh_token: 'mock_refresh_token'
    }
  })
  visit "/auth/google_oauth2/callback"
end

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
