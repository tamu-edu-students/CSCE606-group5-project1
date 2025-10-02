module NavigationHelpers
  def path_for(page_name)
    case page_name.downcase
    when 'dashboard'
      dashboard_path
    when 'calendar'
      calendar_path
    when 'statistics'
      statistics_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end
World(NavigationHelpers)

# Mocking the Google OmniAuth flow.
# It creates a user and then simulates a successful callback from Google.
Given('I am a logged-in user') do
  @current_user = User.create!(
    email: 'testuser@tamu.edu',
    first_name: 'Test',
    last_name: 'User',
    netid: 'testuser'
  )

  # Mock the OmniAuth response
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '123545',
    info: {
      email: @current_user.email,
      first_name: @current_user.first_name,
      last_name: @current_user.last_name
    },
    credentials: {
      token: 'mock_token',
      refresh_token: 'mock_refresh_token'
    }
  })

  # Visit the callback url directly to simulate the login
  visit '/auth/google_oauth2/callback'
end

# Alias the duplicate step to the one above for simplicity.
Given('I am logged in as a student') do
  step 'I am a logged-in user'
end

Given('I am on the {string} page') do |page_name|
  visit path_for(page_name)
end

Given('I am on the dashboard page') do
  visit dashboard_path
end

When('I navigate to my calendar page') do
  visit calendar_path
end

When('I click the {string} link') do |link_text|
  click_link link_text
end

When('I click the "{string}" link in the navigation bar') do |link_text|
  # Scoping the click to within a <nav> element for precision
  within('nav') do
    click_link link_text
  end
end

Then('I should see my calendar events') do
  # Mocking the API response
  mock_event = Google::Apis::CalendarV3::Event.new(
  summary: 'Mock Event for Testing',
  start: Google::Apis::CalendarV3::EventDateTime.new(date_time: Time.now),
  'end': Google::Apis::CalendarV3::EventDateTime.new(date_time: (Time.now + 1.hour))
  )
  mock_response = Google::Apis::CalendarV3::Events.new(items: [mock_event])
  
  # Stubbing the service object to return our mock response
  allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:list_events).and_return(mock_response)

  visit calendar_path
  expect(page).to have_content('Mock Event for Testing')
end

# After logout, the SessionsController redirects to the root path.
Then('I should be redirected to the login page') do
  expect(page).to have_current_path(root_path)
end

Then('I should be on the {string} page') do |page_name|
  expect(page).to have_current_path(path_for(page_name))
end

Then('I should see the main navigation bar') do
  expect(page).to have_css('nav')
end

Then('the navigation bar should contain links to {string}, {string}, and {string}') do |link1, link2, link3|
  within('nav') do
    expect(page).to have_link(link1)
    expect(page).to have_link(link2)
    expect(page).to have_link(link3)
  end
end

Then('I should not see a {string} link') do |link_text|
  expect(page).not_to have_link(link_text)
end

Then('the "{string}" link in the navigation bar should be marked as active') do |link_text|
  within('nav') do
    expect(page).to have_css('a.active', text: link_text)
  end
end

Then('the navigation bar should contain links to {string}, {string}, and {string}') do |link1, link2, link3|
  within('nav') do
    expect(page).to have_link(link1)
    expect(page).to have_link(link2)
    expect(page).to have_link(link3)
  end
end