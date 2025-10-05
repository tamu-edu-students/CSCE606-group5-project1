@javascript
Feature: User Profile Management
  As a user
  I want to access my profile and set my LeetCode username
  So that my information is displayed correctly

  Background:
    Given the following users exist:
      | netid    | email             | first_name | last_name | active |
      | student1 | student1@test.com | John       | Doe      | true   |
    And I am logged in as "student1"

  Scenario: View profile by clicking avatar
    When I click on the user avatar
    Then I should be on the user profile page
    And I should see "John Doe"
    And I should see "No LeetCode username set."

  Scenario: Set LeetCode username
    When I click on the user avatar
    And I fill in "LeetCode Username" with "johndoe123"
    And I press "Update Profile"
    Then I should see "John Doe"
    And I should see "LeetCode Username: johndoe123"
    And I should see "John (johndoe123)" in the navbar

  Scenario: Update LeetCode username
    Given the user "student1" has leetcode_username "olduser"
    When I click on the user avatar
    And I fill in "LeetCode Username" with "newuser"
    And I press "Update Profile"
    Then I should see "LeetCode Username: newuser"
    And I should see "John (newuser)" in the navbar