# Feature: User profile viewing and LeetCode username management
# Given: User is logged in to the application
# When: User accesses profile page and updates LeetCode username
# Then: Profile information is displayed and username is saved for API integration
Feature: User Profile Management
  As a user
  I want to manage my profile
  So that I can update my information
  @requires_login
  Scenario: A logged-in user can view their profile information
    When I visit the user profile API endpoint
    Then the JSON response should contain my user details

  @javascript
  @requires_login
  Scenario: View profile by clicking profile tab
    Given I am on the dashboard
    When I click on the profile tab
    Then I should be on the user profile page
    And I should see "Profile"
    And I should see "Manage your account settings"

  @requires_login
  Scenario: View profile page directly
    When I visit my profile page
    Then I should see the profile form
    And I should see my current information

  @requires_login
  Scenario: Set LeetCode username
    Given I visit my profile page
    When I fill in "LeetCode Username" with "myusername123"
    And I click "Update Profile"
    Then I should see "Profile updated successfully" 
    And my LeetCode username should be "myusername123"

  @requires_login
  Scenario: Update LeetCode username
    Given the user "student" has leetcode_username "oldusername"
    And I visit my profile page
    When I update my LeetCode username to "newusername456"
    Then I should see "Profile updated successfully"
    And my LeetCode username should be "newusername456"

  @requires_login
  Scenario: Update all profile fields
    Given I visit my profile page
    When I fill in the first name field with "John"
    And I fill in the last name field with "Doe"
    And I fill in the personal email field with "john.doe@gmail.com"
    And I fill in "LeetCode Username" with "johndoe123"
    And I click "Update Profile"
    Then I should see "Profile updated successfully"

  @requires_login
  Scenario: Profile tab is visible in navbar
    Given I am on the dashboard
    Then I should see "Profile" in the navbar

  @requires_login
  Scenario: Access profile API when authenticated
    When I visit the user profile API endpoint
    Then the response status should be 200
    And the JSON response should contain my user details

  @requires_login
  Scenario: Access profile API when not authenticated
    When a visitor visits the user profile API endpoint
    Then the response status should be 401
    And the JSON response should contain an error message "Not signed in"
