# Creates a User record in the test database.
Given('a registered student with the email {string} and password {string} exists') do |email, _password|
  User.create!(
    email: email,
    first_name: 'Test',
    last_name: 'User',
    netid: email.split('@').first
  )
end

# Navigates to the root path, which is handled by the LoginController.
Given('I am on the login page') do
  visit root_path
end

# After a successful login, the SessionsController redirects to the dashboard.
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