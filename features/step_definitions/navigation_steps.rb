SIDEBAR_NAV_SELECTOR = '.app-container nav.sidebar'

module NavigationHelpers
  def path_for(page_name)
    case page_name.downcase
    when 'dashboard'
      dashboard_path
    when 'calendar'
      calendar_path
    when 'stats', 'statistics'
      statistics_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end
World(NavigationHelpers)


# This step mocks the full Google OmniAuth login flow.
Given('I am a logged-in user') do
  @current_user ||= User.create!(
    email: 'testuser@tamu.edu',
    first_name: 'Test',
    last_name: 'User',
    netid: 'testuser'
  )

  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '123545',
    info: { email: @current_user.email, first_name: @current_user.first_name, last_name: @current_user.last_name },
    credentials: { token: 'mock_token', refresh_token: 'mock_refresh_token' }
  })

  visit '/auth/google_oauth2/callback'
end

# Alias for convenience
Given('I am logged in as a student') do
  step 'I am a logged-in user'
end

Given('I am on the dashboard page') do
  visit dashboard_path
end

Given('I am on the {string} page') do |page_name|
  visit path_for(page_name)
end

When('I click the "{string}" link in the navigation bar') do |link_text|
  within(SIDEBAR_NAV_SELECTOR) do
    click_link link_text
  end
end

When('I navigate to my calendar page') do
  visit calendar_path
end

Then('I should see the main navigation bar') do
  expect(page).to have_css(SIDEBAR_NAV_SELECTOR)
end

Then('the navigation bar should contain links to {string}, {string}, and {string}') do |link1, link2, link3|
  within(SIDEBAR_NAV_SELECTOR) do
    expect(page).to have_link(link1)
    expect(page).to have_link(link2)
    expect(page).to have_link(link3)
  end
end

Then('the "{string}" link in the navigation bar should be marked as active') do |link_text|
  within(SIDEBAR_NAV_SELECTOR) do
    expect(page).to have_css('a.active', text: link_text)
  end
end

Then('I should be on the {string} page') do |page_name|
  expect(page).to have_current_path(path_for(page_name), wait: 5)
end

Then('I should not see a {string} link') do |link_text|
  expect(page).not_to have_link(link_text)
end
