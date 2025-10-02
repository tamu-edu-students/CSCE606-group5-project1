Given('I am on the new event page') do
  visit new_event_path # TODO: This path needs to be created in routes.rb
end

When('I click the {string} button') do |button_text|
  click_button button_text
end

# This step assumes a successful creation redirects and shows a flash notice.
Then('I should see a confirmation message {string}') do |message|
  expect(page).to have_content(message)
end

# This step assumes you can view the event on your application's calendar page.
Then('I should see {string} on my calendar for {string}') do |event_title, date|
  visit calendar_path(date: Date.parse(date).strftime('%Y-%m-%d'))
  expect(page).to have_content(event_title)
end

# This step would fill out a form but omit one field to test validations.
When('I create an event but leave the {string} blank') do |field_label|
  # Example implementation:
  # fill_in 'Title', with: 'Test Event'
  # fill_in 'Date', with: '2025-10-15'
  # Omit filling in the field_label
end

# This step checks for a validation error message on the form.
Then('I should see an error message "{string}"') do |error_message|
  # This often looks for a specific div containing the error.
  expect(page).to have_content(error_message)
end

# This step confirms that a failed form submission did not create a new record.
Then('the event should not have been created') do
  expect(Event.count).to eq(0)
end