Feature: Weekly Progress Summary Email
  As a student
  I want to receive a weekly summary email of my problem-solving activity
  So that I can track my progress and stay motivated

  Background:
    Given the following users exist:
      | netid    | email             | first_name | last_name | active |
      | student1 | student1@test.com | John       | Doe      | true   |
      | student2 | student2@test.com | Jane       | Smith    | true   |
    And the following LeetCode problems exist:
      | leetcode_id | title      | difficulty |
      | 1           | Two Sum    | easy       |
      | 2           | Add Two    | medium     |
      | 3           | Three Sum  | hard       |
    And the following LeetCode sessions exist for user "student1":
      | scheduled_time       | duration_minutes |
      | 2023-09-20 10:00:00  | 60               |
      | 2023-09-21 10:00:00  | 60               |
      | 2023-09-22 10:00:00  | 60               |
      | 2023-09-23 10:00:00  | 60               |
      | 2023-09-24 10:00:00  | 60               |
      | 2023-09-25 10:00:00  | 60               |
      | 2023-09-26 10:00:00  | 60               |
    And the following solved problems exist for user "student1" in week starting "2023-09-24":
      | problem_id | solved_at            |
      | 1          | 2023-09-24 12:00:00  |
      | 2          | 2023-09-25 12:00:00  |
      | 3          | 2023-09-26 12:00:00  |
      | 1          | 2023-09-26 13:00:00  |
    And the following solved problems exist for user "student1" before week starting "2023-09-24":
      | problem_id | solved_at            |
      | 1          | 2023-09-15 12:00:00  |
      | 2          | 2023-09-16 12:00:00  |
      | 1          | 2023-09-17 12:00:00  |
      | 2          | 2023-09-18 12:00:00  |

  Scenario: Student receives weekly progress summary email
    When the weekly report email task is run for week starting "2023-09-24"
    Then "student1@test.com" should receive an email with subject "Your Weekly LeetCode Progress Summary"
    And the email should contain:
      | content                          |
      | Problems Solved This Week: 4     |
      | Current Streak: 3 days           |
      | Total Problems Solved: 8         |
      | Hardest problem this week: Three Sum (hard) |
    And "student2@test.com" should not receive any email