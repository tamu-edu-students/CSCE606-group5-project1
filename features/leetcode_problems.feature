Feature: Browsing and filtering LeetCode problems

  Background:
    Given there are some LeetCode problems with tags and difficulties
    Given I am a logged-in user and successfully authenticated with Google for leetcode

  Scenario: Viewing the LeetCode problems index
    When I visit the LeetCode problems page
    Then I should see a list of problems
    And I should see the filter form

  Scenario: Filtering problems by difficulty
    When I visit the LeetCode problems page
    And I select "Medium" from the difficulty filter
    And I submit the filter form
    Then I should only see problems with "Medium" difficulty

  Scenario: Filtering problems by tag
    When I visit the LeetCode problems page
    And I select "Array" from the tag filter
    And I submit the filter form
    Then I should only see problems with the tag "Array"

  Scenario: Filtering problems by multiple tags
    When I visit the LeetCode problems page
    And I select "Array" and "Hash Table" from the tag filter
    And I submit the filter form
    Then I should only see problems that include all of "Array" and "Hash Table"

  Scenario: Paginating through problems
    Given there are more than 10 LeetCode problems
    When I visit the LeetCode problems page
    Then I should see the pagination controls

  Scenario: No problems match filters
    When I visit the LeetCode problems page
    And I select a difficulty and tag that don't match any problems
    And I submit the filter form
    Then I should see the no problems found message