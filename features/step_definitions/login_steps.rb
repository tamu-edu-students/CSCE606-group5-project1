# This step prepares the OmniAuth mock. It ensures that when the "Sign in" button
# is clicked, the application will receive a successful callback for this user.
Given('a student with the email {string} can be authenticated by Google') do |email|
  # This ensures a user record exists to be found or updated by the SessionsController.
  User.create!(
    email: email,
    first_name: 'Test',
    last_name: 'User',
    netid: email.split('@').first
  )

  # This mocks the data that Google would send back to your application after a successful login.
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '123545',
    info: {
      email: email,
      first_name: 'Test',
      last_name: 'User'
    },
    credentials: {
      token: 'mock_token',
      refresh_token: 'mock_refresh_token'
    }
  })
end

Given('I am on the login page') do
  visit root_path
end

Then('I should be redirected to the dashboard') do
  expect(page).to have_current_path(dashboard_path)
end

# The SessionsController sets a notice on successful sign-in.
Then('I should see a success message {string}') do |message|
  expect(page).to have_content(message)
end

# The SessionsController sets an alert on login failure.
Then('I should see an error message {string}') do |message|
  expect(page).to have_content(message)
end

# On a failed login attempt, the user should remain on the login page (root_path).
Then('I should still be on the login page') do
  expect(page).to have_current_path(root_path)
end