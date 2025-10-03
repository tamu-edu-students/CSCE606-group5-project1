Feature: User Authentication
  As a student
  I want to log in and out of my account
  So that I can securely access my personal information

  # This is the "happy path" for a successful login.
  # It checks for redirection and a success message.
  Scenario: Successful login via Google
    Given a student with the email "student@tamu.edu" can be authenticated by Google
    And I am on the login page
    When I click the "Sign in with Google" button
    Then I should be redirected to the dashboard
    And I should see a success message "Signed in as student@tamu.edu"

  # This is a "sad path" for handling incorrect credentials.
  # It ensures an error is shown and the user is not granted access.
  Scenario: Failed login with incorrect password
    Given a registered student with the email "student@example.com" and password "password123" exists
    And I am on the login page
    When I fill in "Email" with "student@example.com"
    And I fill in "Password" with "wrong-password"
    And I click the "Log In" button
    Then I should see an error message "Invalid email or password."
    And I should still be on the login page

  # This scenario covers the full session lifecycle: login, confirm access, logout, confirm logged out state.
  # It directly tests the acceptance criteria for session management.
  @javascript
  Scenario: User logs out successfully
    Given I am logged in as a student
    When I navigate to my calendar page
    Then I should see my calendar events
    When I click the "Logout" link
    Then I should be redirected to the login page
    And I should see a confirmation message "You have been successfully logged out."
    And I should not see a "Logout" link