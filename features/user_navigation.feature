Feature: Application Navigation
As a user
I want a clear and consistent navigation bar
So that I can easily move between the main sections of the application

Background:
Given I am a logged-in user
Scenario Outline: Navigation bar is visible on all main pages
Given I am on the "<page_name>" page
Then I should see the main navigation bar
And the navigation bar should contain links to "Dashboard", "Calendar" and "Statistics"

Examples:
| page_name   |
| "Dashboard" |
| "Calendar"  |
| "Statistics"|

Scenario Outline: Navigating to different sections using the navigation bar
Given I am on the dashboard page
And I am successfully authenticated with Google
When I click the "<link_name>" link in the navigation bar
Then I should be on the <destination_page> page

Examples:
| link_name    | destination_page |
| "Calendar"   | "Calendar"       |
| "Statistics" | "Statistics"     |
| "Dashboard"  | "Dashboard"      |

Scenario Outline: The current page is highlighted in the navigation bar
Given I am on the "<page_name>" page
Then the "<link_name>" link in the navigation bar should be marked as active

Examples:
| link_name    | destination_page |
| "Calendar"   | "Calendar"       |
| "Statistics" | "Statistics"     |
| "Dashboard"  | "Dashboard"      |