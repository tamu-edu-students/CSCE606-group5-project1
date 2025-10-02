@timecop
Feature: LeetCode Weekly Activity Summary
  As a user tracking my coding skills
  I want to see a weekly summary of my LeetCode activity
  So that I can monitor my progress and stay motivated.

  Background:
    Given I am a logged-in user

  # This is the "happy path" where the user has been active and solved
  # problems of varying difficulties.
  Scenario: Viewing the summary with activity across all difficulties
    Given I have solved the following LeetCode problems in the last 7 days:
      | Title                     | Difficulty | Solved On  |
      | "Two Sum"                 | Easy       | 2 days ago |
      | "Valid Parentheses"       | Easy       | 3 days ago |
      | "Longest Substring"       | Medium     | 1 day ago  |
      | "3Sum"                    | Medium     | 4 days ago |
      | "Median of Two Sorted Arrays" | Hard       | 6 days ago |
    # This next step is crucial to ensure we're correctly handling the time window.
    And I also solved "Reverse Integer" (Easy) 8 days ago
    When I navigate to my LeetCode stats page
    Then I should see a "Weekly Statistics" section for the period "September 26, 2025 - October 2, 2025"
    And within the summary, I should see "Total Solved: 5"
    And the summary should show the following breakdown:
      | Difficulty | Count |
      | Easy       | 2     |
      | Medium     | 2     |
      | Hard       | 1     |

  # This edge case handles what a new user or an inactive user would see.
  # It's important to show a helpful message instead of an empty or broken component.
  Scenario: Viewing the summary with no activity in the past week
    Given I have not solved any LeetCode problems in the last 7 days
    When I navigate to my LeetCode stats page
    Then I should see a "Weekly Statistics" section
    And I should see a message like "No LeetCode activity recorded this week. Keep going!"
    And I should not see a difficulty breakdown

  # This scenario ensures the summary correctly handles cases where the user
  # has only focused on certain types of problems.
  Scenario: Viewing the summary with activity in only some difficulties
    Given I have solved the following LeetCode problems in the last 7 days:
      | Title             | Difficulty | Solved On  |
      | "Merge Intervals" | Medium     | 1 day ago  |
      | "Coin Change"     | Medium     | 5 days ago |
    When I navigate to my LeetCode stats page
    Then I should see a "Weekly Statistics" section
    And within the summary, I should see "Total Solved: 2"
    And the summary should show the following breakdown:
      | Difficulty | Count |
      | Easy       | 0     |
      | Medium     | 2     |
      | Hard       | 0     |