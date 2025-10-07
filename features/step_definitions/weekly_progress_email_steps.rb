Given('the following users exist:') do |table|
  table.hashes.each do |row|
    User.create!(
      netid: row['netid'],
      email: row['email'],
      first_name: row['first_name'],
      last_name: row['last_name'],
      active: row['active'] == 'true',
      personal_email: row['personal_email']
    )
  end
end

Given('the following LeetCode problems exist:') do |table|
  table.hashes.each do |row|
    LeetCodeProblem.create!(
      leetcode_id: row['leetcode_id'].to_i,
      title: row['title'],
      difficulty: row['difficulty'],
      url: "https://leetcode.com/problems/#{row['title'].parameterize}",
      tags: "Mock Tag",
    )
  end
end

Given('the following LeetCode sessions exist for user {string}:') do |netid, table|
  user = User.find_by(netid: netid)
  table.hashes.each do |row|
    LeetCodeSession.create!(
      user: user,
      scheduled_time: DateTime.parse(row['scheduled_time']),
      duration_minutes: row['duration_minutes'].to_i,
      status: 'completed'
    )
  end
end

Given('the following solved problems exist for user {string} in week starting {string}:') do |netid, week_start, table|
  user = User.find_by(netid: netid)
  table.hashes.each do |row|
    problem = LeetCodeProblem.find_by(leetcode_id: row['problem_id'].to_i)
    session = user.leet_code_sessions.find_by('scheduled_time >= ?', DateTime.parse(week_start))
    
    LeetCodeSessionProblem.create!(
      leet_code_session: session || user.leet_code_sessions.first,
      leet_code_problem: problem,
      solved_at: DateTime.parse(row['solved_at']),
      solved: true
    )
  end
end

Given('the following solved problems exist for user {string} before week starting {string}:') do |netid, week_start, table|
  user = User.find_by(netid: netid)
  table.hashes.each do |row|
    problem = LeetCodeProblem.find_by(leetcode_id: row['problem_id'].to_i)
    session = user.leet_code_sessions.where('scheduled_time < ?', DateTime.parse(week_start)).first
    
    LeetCodeSessionProblem.create!(
      leet_code_session: session || user.leet_code_sessions.first,
      leet_code_problem: problem,
      solved_at: DateTime.parse(row['solved_at']),
      solved: true
    )
  end
end

When('the weekly report email task is run for week starting {string}') do |week_start|
  # Clear any existing emails
  ActionMailer::Base.deliveries.clear
  
  # Run the weekly report task
  # Assuming you have a mailer or service class to handle this
  week_date = Date.parse(week_start)
  
  User.where(active: true).where.not(personal_email: [nil, '']).each do |user|
    # Generate report data
    report_data = generate_weekly_report(user, week_date)
    
    # Send email if user has activity
    if report_data[:problems_solved] > 0
      WeeklyReportMailer.summary(user, report_data).deliver_now
    end
  end
end

Then('{string} should receive an email with subject {string}') do |email, subject|
  email_sent = ActionMailer::Base.deliveries.find { |mail| mail.to.include?(email) }
  expect(email_sent).not_to be_nil, "Expected email to #{email} but none was sent"
  expect(email_sent.subject).to eq(subject)
end

Then('{string} should not receive any email') do |email|
  emails_to_address = ActionMailer::Base.deliveries.select { |mail| mail.to.include?(email) }
  expect(emails_to_address).to be_empty, 
    "Expected no emails to #{email} but #{emails_to_address.count} were sent"
end

# Helper method to generate weekly report data
def generate_weekly_report(user, week_start_date) 
  week_end_date = week_start_date + 6.days 
  # Get solved problems for the week 
  solved_this_week = LeetCodeSessionProblem.joins(:leet_code_session)
    .where(leet_code_sessions: { user: user })
    .where('leet_code_session_problems.solved_at BETWEEN ? AND ?', week_start_date.beginning_of_day, week_end_date.end_of_day) 
    .where(solved: true)
  # Get all solved problems 
  total_solved = LeetCodeSessionProblem.joins(:leet_code_session) 
    .where(leet_code_sessions: { user: user })
    .where(solved: true)

  # Calculate streak 
  streak = calculate_streak(user, week_end_date)
  # Find hardest problem
  hardest_problem = solved_this_week.joins(:leet_code_problem) 
    .order(Arel.sql("CASE WHEN leet_code_problems.difficulty = 'hard' THEN 1 
                 WHEN leet_code_problems.difficulty = 'medium' THEN 2 
                 ELSE 3 END"))
    .first&.leet_code_problem

  { 
    problems_solved: solved_this_week.count, 
    streak: streak, total_problems: total_solved.count, 
    hardest_problem: hardest_problem 
  } 
end

def calculate_streak(user, end_date)
  streak = 0
  current_date = end_date
  
  loop do
    solved_on_date = LeetCodeSessionProblem.joins(:leet_code_session)
      .where(leet_code_sessions: { user: user })
      .where('DATE(leet_code_session_problems.solved_at) = ?', current_date)
      .where(solved: true)
      .exists?
    
    break unless solved_on_date
    
    streak += 1
    current_date -= 1.day
  end
  
  streak
end