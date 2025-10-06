Feature: User Profile Management
  As a user
  I want to access my profile and set my LeetCode username
  So that my information is displayed correctly

  @requires_login
  Scenario: A logged-in user can view their profile information
    When I visit the user profile API endpoint
    Then the JSON response should contain my user details

  @javascript
  @requires_login
  Scenario: View profile by clicking avatar
    When I click on the user avatar
    Then I should be on the user profile page
    And I should see "John Doe"
    And I should see "No LeetCode username set."

  @javascript
  @requires_login
  Scenario: Set LeetCode username
    When I click on the user avatar
    And I fill in "LeetCode Username" with "johndoe123"
    And I press "Update Profile"
    Then I should see "John Doe"
    And I should see "LeetCode Username: johndoe123"
    And I should see "John (johndoe123)" in the navbar

  @javascript
  @requires_login
  Scenario: Update LeetCode username
    Given the user "student1" has leetcode_username "olduser"
    When I click on the user avatar
    And I fill in "LeetCode Username" with "newuser"
    And I press "Update Profile"
    Then I should see "LeetCode Username: newuser"
    And I should see "John (newuser)" in the navbar

  Scenario: A visitor cannot view profile information
    When a visitor visits the user profile API endpoint
    Then the JSON response should contain an error message "Authentication required"