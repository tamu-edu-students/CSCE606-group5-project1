# Feature: Navigation bar functionality across application pages
# Given: User is logged in and on any application page
# When: User clicks navigation links
# Then: User can navigate between Dashboard, Calendar, and Statistics pages
Feature: Application Navigation
  As a user
  I want a clear and consistent navigation bar
  So that I can easily move between the main sections of the application

  Background:
    Given I am a logged-in user

  Scenario: Navigation bar is visible on the Dashboard page
    Given I am on the "Dashboard" page
    Then I should see the main navigation bar
    And the navigation bar should contain links to "Dashboard", "Calendar", and "Statistics"

  Scenario: Navigation bar is visible on the Calendar page
    Given I am on the "Calendar" page
    Then I should see the main navigation bar
    And the navigation bar should contain links to "Dashboard", "Calendar", and "Statistics"

  Scenario: Navigation bar is visible on the Statistics page
    Given I am on the "Statistics" page
    Then I should see the main navigation bar
    And the navigation bar should contain links to "Dashboard", "Calendar", and "Statistics"

  Scenario: Navigating from the Dashboard to the Calendar page
    Given I am on the dashboard page
    When I click the "Calendar" link in the navigation bar
    Then I should be on the "Calendar" page

  Scenario: Navigating from the Dashboard to the Statistics page
    Given I am on the dashboard page
    When I click the "Statistics" link in the navigation bar
    Then I should be on the "Statistics" page

  Scenario: Navigating from the Dashboard to the Dashboard page
    Given I am on the dashboard page
    When I click the "Dashboard" link in the navigation bar

  Scenario: The Dashboard link is active on the Dashboard page
    Given I am on the "Dashboard" page
    Then the "Dashboard" link in the navigation bar should be marked as active

  Scenario: The Calendar link is active on the Calendar page
    Given I am on the "Calendar" page
    Then the "Calendar" link in the navigation bar should be marked as active

  Scenario: The Statistics link is active on the Statistics page
    Given I am on the "Statistics" page
    Then the "Statistics" link in the navigation bar should be marked as active