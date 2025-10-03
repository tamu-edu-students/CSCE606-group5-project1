Feature: Create Calendar Event
  As a student
  I want to create a new event on my calendar
  So that I can organize and track my activities

  # This is the "happy path" scenario, covering successful creation.
  Scenario: Successfully create a new event with all required fields
    Given I am on the new event page
    When I fill in "Title" with "Midterm Study Group"
    And I fill in "Date" with "2025-10-15"
    And I fill in "Time" with "14:00"
    And I fill in "Description" with "Meet at the library, Room 201"
    And I click the "Create Event" button
    Then I should see a confirmation message "Event was successfully created."
    And I should see "Midterm Study Group" on my calendar for "October 15, 2025"


  # This is the "sad path" or validation scenario.
  Scenario Outline: Attempt to create an event with missing required information
    Given I am on the new event page
    When I create an event but leave the <field> blank
    And I click the "Create Event" button
    Then I should see an error message "<error_message>"
    And the event should not have been created

    Examples:
      | field   | error_message          |
      | "Title" | "Title can't be blank" |
      | "Date"  | "Date can't be blank"  |
      | "Time"  | "Time can't be blank"  |