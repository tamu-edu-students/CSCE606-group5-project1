# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
# Demo data for weekly progress summary email feature

# Create demo users
demo_users = [
  { netid: "demo_student1", email: "demo_student1@example.com", first_name: "Alice", last_name: "Johnson", active: true, role: "student" },
  { netid: "demo_student2", email: "demo_student2@example.com", first_name: "Bob", last_name: "Smith", active: true, role: "student" },
  { netid: "inactive_student", email: "inactive@example.com", first_name: "Charlie", last_name: "Brown", active: false, role: "student" }
]

demo_users.each do |user_attrs|
  User.find_or_create_by!(netid: user_attrs[:netid]) do |user|
    user.assign_attributes(user_attrs)
  end
end

# Create demo LeetCode problems
demo_problems = [
  { leetcode_id: "1", title: "Two Sum", difficulty: "easy" },
  { leetcode_id: "2", title: "Add Two Numbers", difficulty: "medium" },
  { leetcode_id: "3", title: "Longest Substring Without Repeating Characters", difficulty: "medium" },
  { leetcode_id: "4", title: "Median of Two Sorted Arrays", difficulty: "hard" },
  { leetcode_id: "5", title: "Longest Palindromic Substring", difficulty: "medium" }
]

demo_problems.each do |problem_attrs|
  LeetCodeProblem.find_or_create_by!(leetcode_id: problem_attrs[:leetcode_id]) do |problem|
    problem.assign_attributes(problem_attrs)
  end
end

# Create demo sessions and solved problems for active users
active_users = User.where(active: true)

active_users.each do |user|
  # Create sessions over the past few weeks
  (0..4).each do |week_offset|
    week_start = Time.zone.now.beginning_of_week(:sunday) - week_offset.weeks

    # Create 3-5 sessions per week
    rand(3..5).times do |day_offset|
      session_time = week_start + day_offset.days + rand(9..17).hours

      session = LeetCodeSession.find_or_create_by!(
        user: user,
        scheduled_time: session_time,
        duration_minutes: 60
      )

      # Add 1-3 solved problems per session
      solved_problems = LeetCodeProblem.all.sample(rand(1..3))
      solved_problems.each do |problem|
        LeetCodeSessionProblem.find_or_create_by!(
          leet_code_session: session,
          leet_code_problem: problem
        ) do |sp|
          sp.solved = true
          sp.solved_at = session_time + rand(10..50).minutes
        end
      end
    end
  end

  # Update user's streak data
  user.update(
    current_streak: rand(1..10),
    longest_streak: rand(10..30)
  )
end

puts "Demo data created for #{active_users.count} active users with weekly progress tracking."
#   end
