When('I click the {string} button') do |button_text|
  click_link_or_button(button_text)
end
When('I press {string}') do |button_text|
  click_button(button_text)
end


When('I fill in {string} with {string}') do |field, value|
  fill_in(field, with: value)
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end
