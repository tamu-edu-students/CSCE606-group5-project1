def mock_google_event(id, summary)
  instance_double(Google::Apis::CalendarV3::Event,
                  id: id,
                  summary: summary,
                  start: instance_double(Google::Apis::CalendarV3::EventDateTime, date_time: Time.current, date: nil),
                  end: instance_double(Google::Apis::CalendarV3::EventDateTime, date_time: Time.current + 1.hour, date: nil),
                  location: 'Mock Location',
                  description: 'Mock Description')
end

Before do
  @service_double = instance_double(Google::Apis::CalendarV3::CalendarService)
  allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(@service_double)
  allow(@service_double).to receive(:authorization=)
  allow(@service_double).to receive(:list_events).and_return(
    instance_double(Google::Apis::CalendarV3::Events, items: [])
  )

  allow_any_instance_of(Api::CalendarController).to receive(:calendar_service_or_unauthorized).and_return(@service_double)
  allow_any_instance_of(Signet::OAuth2::Client).to receive(:refresh!)
end

Given('I am on the new event page') do
  visit calendar_path
end

Then('I should see a confirmation message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should see {string} on my calendar for {string}') do |title, date|
  visit calendar_path(date: Date.parse(date).strftime('%Y-%m-%d'))
  expect(page).to have_content(title)
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

Given('my Google Calendar is ready to create an event') do
  allow(@service_double).to receive(:insert_event).and_return(mock_google_event('new_event_id', 'New Study Session'))
end

Given('my Google Calendar has an event titled {string} with id {string}') do |title, event_id|
  mock_event = mock_google_event(event_id, title)
  allow(@service_double).to receive(:list_events).and_return(
    instance_double(Google::Apis::CalendarV3::Events, items: [ mock_event ])
  )
  allow(@service_double).to receive(:get_event).with('primary', event_id).and_return(mock_event)
  allow(@service_double).to receive(:update_event).with('primary', event_id, an_instance_of(Google::Apis::CalendarV3::Event))
                                               .and_return(mock_google_event(event_id, 'New Updated Title'))
  allow(@service_double).to receive(:delete_event).with('primary', event_id)
end

When('I am on the calendar page') do
  visit calendar_path
end

When('I visit the edit page for the event {string}') do |event_id|
  visit edit_calendar_event_path(event_id)
end

When('I click the {string} button for {string}') do |button_text, title|
  accept_confirm do
    find('.event-card', text: title).click_button(button_text)
  end
end

Then('I should see the success message {string}') do |message|
  expect(page).to have_css('.flash-success', text: message)
end

Then('I should see the error message {string}') do |message|
  expect(page).to have_css('.flash-alert', text: message)
end

Given('I am a logged-in user and successfully authenticated with Google') do
  @current_user = create(:user, email: 'testuser@tamu.edu', first_name: 'Test', last_name: 'User')
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    provider: "google_oauth2",
    uid: "123456789",
    info: {
      name: @current_user.full_name,
      email: @current_user.email,
      first_name: @current_user.first_name,
      last_name: @current_user.last_name
    },
    credentials: {
      token: "mock_google_token",
      refresh_token: "mock_google_refresh_token",
      expires_at: Time.now.to_i + 3600
    }
  })

  visit "/auth/google_oauth2/callback"
end
