Given('there are some LeetCode problems with tags and difficulties') do
  LeetCodeProblem.create!(
    title: "Two Sum",
    difficulty: "Easy",
    tags: "Array, Hash Table",
    url: "https://leetcode.com/problems/two-sum",
    leetcode_id: 1,
  )
  LeetCodeProblem.create!(
    title: "Longest Substring",
    difficulty: "Medium",
    tags: "Hash Table, Sliding Window",
    url: "https://leetcode.com/problems/longest-substring",
    leetcode_id: 2,
  )
end

Given('I am a logged-in user and successfully authenticated with Google for leetcode') do
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

When('I visit the LeetCode problems page') do
  visit leetcode_path
end

Then('I should see a list of problems') do
  within ".leet-content" do
    expect(page).to have_css(".event-card", minimum: 1)
  end
end

Then('I should see the filter form') do
  expect(page).to have_selector("form.filters-form")
  expect(page).to have_field("difficulty")
  expect(page).to have_field("tags[]")
end

When('I select {string} from the difficulty filter') do |difficulty|
  within ".filters-form" do
    select difficulty, from: "difficulty"
  end
end

When('I select {string} from the tag filter') do |tag|
  within ".filters-form" do
    select tag, from: "tags[]"
  end
end

When('I select {string} and {string} from the tag filter') do |tag1, tag2|
  within ".filters-form" do
    select tag1, from: "tags[]"
    select tag2, from: "tags[]"
  end
end

When('I submit the filter form') do
  within ".filters-form" do
    click_button "Filter"
  end
end

Then('I should only see problems with {string} difficulty') do |difficulty|
  within ".leet-content" do
    all('.event-card').each do |card|
      expect(card).to have_text("Difficulty: #{difficulty}")
    end
  end
end

Then('I should only see problems with the tag {string}') do |tag|
  within ".leet-content" do
    all('.event-card').each do |card|
      expect(card).to have_text(tag)
    end
  end
end

Then('I should only see problems that include all of {string} and {string}') do |tag1, tag2|
  within ".leet-content" do
    all('.event-card').each do |card|
      expect(card).to have_text(tag1)
      expect(card).to have_text(tag2)
    end
  end
end

Given('there are more than 10 LeetCode problems') do
  15.times do |i|
    LeetCodeProblem.create!(
      title: "Problem #{i + 1}",
      difficulty: "Easy",
      tags: "Array",
      url: "https://leetcode.com/problems/#{i + 1}",
      leetcode_id: i + 5,
    )
  end
end

Then('I should see the pagination controls') do
  within '.pagination-container' do
    expect(page).to have_css('.pagination')
  end
end

When('I select a difficulty and tag that don\'t match any problems') do
  within ".filters-form" do
    select "Hard", from: "difficulty"
    select 'Array', from: "tags[]"
  end
end

Then('I should see the no problems found message') do
  within ".leet-content" do
    expect(page).to have_content("No problems found.")
  end
end
