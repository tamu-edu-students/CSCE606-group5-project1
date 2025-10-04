Given("I am on the LeetCode entries page") { visit leet_code_entries_path }

When('I follow {string}') do |string|
  click_link string
end

When('I select {string} from {string}') do |option, field|
  select option, from: field
end

Given("the following users exist:") do |table|
  table.hashes.each do |user_attrs|
    User.create!(user_attrs.merge(netid: user_attrs["netid"] || SecureRandom.hex(4)))
  end
end

Given("the following LeetCode problems exist:") do |table|
  table.hashes.each do |problem_attrs|
    LeetCodeProblem.create!(problem_attrs)
  end
end

Given("the following LeetCode sessions exist for user {string}:") do |netid, table|
  user = User.find_by(netid: netid)
  table.hashes.each do |session_attrs|
    LeetCodeSession.create!(session_attrs.merge(user: user))
  end
end

Given("the following solved problems exist for user {string} in week starting {string}:") do |netid, week_start, table|
  user = User.find_by(netid: netid)
  table.hashes.each do |problem_attrs|
    session = user.leet_code_sessions.first # Assuming one session per user for simplicity
    problem = LeetCodeProblem.find_by(leetcode_id: problem_attrs["problem_id"])
    LeetCodeSessionProblem.create!(
      leet_code_session: session,
      leet_code_problem: problem,
      solved: true,
      solved_at: problem_attrs["solved_at"]
    )
  end
end

Given("the following solved problems exist for user {string} before week starting {string}:") do |netid, week_start, table|
  user = User.find_by(netid: netid)
  table.hashes.each do |problem_attrs|
    session = user.leet_code_sessions.first
    problem = LeetCodeProblem.find_by(leetcode_id: problem_attrs["problem_id"])
    LeetCodeSessionProblem.create!(
      leet_code_session: session,
      leet_code_problem: problem,
      solved: true,
      solved_at: problem_attrs["solved_at"]
    )
  end
end

When("the weekly report email task is run for week starting {string}") do |week_start|
  ENV['WEEK_START'] = week_start
  Rake::Task["weekly_report:send"].reenable
  Rake::Task["weekly_report:send"].invoke
  ENV.delete('WEEK_START')
end

Then("{string} should receive an email with subject {string}") do |email, subject|
  mail = ActionMailer::Base.deliveries.find { |m| m.to.include?(email) && m.subject == subject }
  expect(mail).to be_present
  @last_email = mail
end

Then("the email should contain:") do |table|
  table.hashes.each do |row|
    expect(@last_email.body.encoded).to include(row["content"])
  end
end

Then("{string} should not receive any email") do |email|
  mail = ActionMailer::Base.deliveries.find { |m| m.to.include?(email) }
  expect(mail).to be_nil
end
