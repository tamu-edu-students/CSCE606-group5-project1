@timecop
Feature: LeetCode Weekly Activity Summary
As a user tracking my coding skills
I want to see a weekly summary of my LeetCode activity
So that I can monitor my progress and stay motivated.

Background:
Given I am a logged-in user

Scenario: Viewing the summary with activity
Given I have the following LeetCode stats for the last 7 days:
| Problems Solved This Week | Current Streak | Total Problems Solved |
| 5                         | 14             | 150                   |
When I navigate to my LeetCode stats page
Then I should see a "Weekly Statistics" section
And I should see a stat card with title "Problems Solved This Week" and value "5"
And I should see a stat card with title "Current Streak" and value "14"
And I should see a stat card with title "Total Problems Solved" and value "150"

Scenario: Viewing the summary with no activity in the past week
Given I have no LeetCode stats for the last 7 days
When I navigate to my LeetCode stats page
Then I should see a "Weekly Statistics" section
And I should see the message "No LeetCode activity recorded this week. Keep going!"
And I should not see any stat cards