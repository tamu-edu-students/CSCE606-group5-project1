@timecop
Feature: LeetCode Statistics
As a user tracking my coding skills
I want to see my LeetCode solved problems count
So that I can monitor my progress.

Background:
Given I am a logged-in user

Scenario: Viewing stats with LeetCode username
Given I have a LeetCode username set
When I navigate to my LeetCode stats page
Then I should see the solved problems statistics

Scenario: Viewing stats without LeetCode username
Given I have no LeetCode username set
When I navigate to my LeetCode stats page
Then I should see zero statistics