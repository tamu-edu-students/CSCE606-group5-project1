Feature: Calendar
  As a user, I want to manage my Google Calendar events through the application
  so that I can plan my study sessions effectively.

  Background:
    Given I am a logged-in user and successfully authenticated with Google

  Scenario: A user can create a new timed event
    Given my Google Calendar is ready to create an event
    When I am on the calendar page
    And I follow "Add Event"
    And I fill in "Title" with "New Study Session"
    And I fill in "Date" with "2025-10-25"
    And I fill in "Start" with "2025-10-25T14:00"
    And I fill in "End" with "2025-10-25T15:00"
    And I click "Add Event"
    Then I should see the success message "Event successfully created."

  Scenario: A user cannot create an event without a title
    Given I am on the calendar page
    When I click "Add Event"
    And I click "Add Event"
    Then I should see the error message "Event name is required."

  Scenario: A user can update an existing event
    Given my Google Calendar has an event titled "Old Title" with id "event123"
    When I visit the edit page for the event "event123"
    And I fill in "Title" with "New Updated Title"
    And I click "Update"
    Then I should see the success message "Event successfully updated."

  @javascript
  Scenario: A user can delete an event
    Given my Google Calendar has an event titled "Event to Delete" with id "event456"
    When I am on the calendar page
    And I click the "Delete" button for "Event to Delete"
    Then I should see the success message "Event deleted."
