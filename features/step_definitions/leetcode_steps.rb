Given("I am on the LeetCode entries page") { visit leet_code_entries_path }

When('I follow {string}') do |string|
  click_link string
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I select {string} from {string}') do |option, field|
  select option, from: field
end

When('I press {string}') do |button|
  click_button button
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end
