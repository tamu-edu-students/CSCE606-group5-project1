Given('I am on the new event page') do
  visit new_event_path # TODO: This path needs to be created in routes.rb
end

Then('I should see a confirmation message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should see {string} on my calendar for {string}') do |event_title, date|
  visit calendar_path(date: Date.parse(date).strftime('%Y-%m-%d'))
  expect(page).to have_content(event_title)
end

When('I create an event but leave the {string} blank') do |field_label|
end

Then('I should see an error message "{string}"') do |error_message|
  expect(page).to have_content(error_message)
end

Then('the event should not have been created') do
  expect(Event.count).to eq(0)
end

Then('I should see my calendar events') do
  mock_event = Google::Apis::CalendarV3::Event.new(
    summary: 'Mock Event for Testing',
    start: Google::Apis::CalendarV3::EventDateTime.new(date_time: Time.now),
    'end': Google::Apis::CalendarV3::EventDateTime.new(date_time: (Time.now + 1.hour))
  )
  mock_response = Google::Apis::CalendarV3::Events.new(items: [ mock_event ])
  allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:list_events).and_return(mock_response)
  visit calendar_path
  expect(page).to have_content('Mock Event for Testing')
end
