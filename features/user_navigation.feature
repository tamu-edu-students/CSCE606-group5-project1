Feature: Application Navigation
  As a user
  I want a clear and consistent navigation bar
  So that I can easily move between the main sections of the application

  Background:
    Given I am a logged-in user

  # This Scenario Outline ensures the navigation bar is consistently displayed
  # across all the key pages of the application.
  Scenario Outline: Navigation bar is visible on all main pages
    Given I am on the <page_name> page
    Then I should see the main navigation bar
    And the navigation bar should contain links to "Dashboard", "Calendar" and "Statistics"

    Examples:
      | page_name   |
      | "Dashboard" |
      | "Calendar"  |
      | "Statistics"|

  # This Scenario Outline tests that each link in the navigation bar
  # correctly takes the user to its intended destination.
  Scenario Outline: Navigating to different sections using the navigation bar
    Given I am on the dashboard page
    When I click the "<link_name>" link in the navigation bar
    Then I should be on the <destination_page> page

    Examples:
    | link_name    | destination_page |
    | "Calendar"   | "Calendar"       |
    | "Statistics" | "Statistics"     |
    | "Dashboard"  | "Dashboard"      |

  # This is a good "UI polish" test. It ensures the user gets visual
  # feedback about which page they are currently on.
  Scenario Outline: The current page is highlighted in the navigation bar
    Given I am on the <page_name> page
    Then the "<link_name>" link in the navigation bar should be marked as active

    Examples:
    | link_name    | destination_page |
    | "Calendar"   | "Calendar"       |
    | "Statistics" | "Statistics"     |
    | "Dashboard"  | "Dashboard"      |