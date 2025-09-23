Feature: Create LeetCode entry
  As a student
  I want to record a LeetCode problem I solved
  So that I can track my practice

  Scenario: Create a valid entry
    Given I am on the LeetCode entries page
    When I follow "Add Entry"
    And I fill in "Problem Number*" with "1"
    And I select "Easy" from "Difficulty (leave blank to auto-fetch from API)*"
    And I press "Create"
    Then I should see "LeetCode entry created!"
    And I should see "Two Sum"

  Scenario: Missing required fields
    Given I am on the LeetCode entries page
    When I follow "Add Entry"
    And I press "Create"
    Then I should see "can't be blank"
