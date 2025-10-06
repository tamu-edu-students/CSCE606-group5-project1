require "rails_helper"

# Tests Reports::WeeklyStats service for generating user progress statistics
RSpec.describe Reports::WeeklyStats do
  let(:user) { User.create!(netid: "test_user", email: "test@example.com", first_name: "Test", last_name: "User", active: true) }
  let(:week_start) { Time.zone.parse("2023-09-24 00:00:00") } # Sunday
  let(:service) { described_class.new(user, week_start: week_start) }

  # Tests main service method that generates complete statistics report
  describe "#call" do
    # Tests behavior when user has no solved problems
    context "with no solved problems" do
      # Tests that service returns zero values for all metrics when no problems solved
      it "returns zero stats" do
        result = service.call
        expect(result[:weekly_solved_count]).to eq(0)
        expect(result[:current_streak_days]).to eq(0)
        expect(result[:total_solved_all_time]).to eq(0)
        expect(result[:highlight]).to eq("")
      end
    end

    # Tests behavior when user has solved problems within the target week
    context "with solved problems" do
      let!(:session) { LeetCodeSession.create!(user: user, scheduled_time: Time.zone.now, duration_minutes: 60) }
      let!(:problem) { LeetCodeProblem.create!(leetcode_id: "1", title: "Test Problem", difficulty: "hard") }
      let!(:solved_problem) do
        LeetCodeSessionProblem.create!(
          leet_code_session: session,
          leet_code_problem: problem,
          solved: true,
          solved_at: week_start + 1.day
        )
      end

      # Tests that weekly problem count is calculated correctly
      it "counts weekly solved problems" do
        result = service.call
        expect(result[:weekly_solved_count]).to eq(1)
      end

      # Tests streak calculation logic
      it "calculates current streak" do
        # Create a solved problem today
        LeetCodeSessionProblem.create!(
          leet_code_session: session,
          leet_code_problem: LeetCodeProblem.create!(leetcode_id: "2", title: "Another Problem", difficulty: "easy"),
          solved: true,
          solved_at: Time.zone.today
        )

        result = service.call
        expect(result[:current_streak_days]).to eq(1)
      end

      # Tests that hardest problem is identified and included in highlights
      it "includes hardest problem in highlight" do
        result = service.call
        expect(result[:highlight]).to include("Hardest problem this week: #{problem.title} (hard)")
      end

      # Tests that historical longest streak is included in highlights
      it "includes longest streak in highlight" do
        user.update(longest_streak: 5)
        result = service.call
        expect(result[:highlight]).to include("Longest streak: 5 days")
      end
    end

    # Tests that problems outside the target week are handled correctly
    context "with problems outside the week" do
      let!(:session) { LeetCodeSession.create!(user: user, scheduled_time: Time.zone.now, duration_minutes: 60) }
      let!(:problem) { LeetCodeProblem.create!(leetcode_id: "3", title: "Old Problem", difficulty: "easy") }
      let!(:solved_problem) do
        LeetCodeSessionProblem.create!(
          leet_code_session: session,
          leet_code_problem: problem,
          solved: true,
          solved_at: week_start - 1.day
        )
      end

      # Tests that problems solved outside target week don't affect weekly count but do affect total
      it "does not count problems outside the week" do
        result = service.call
        expect(result[:weekly_solved_count]).to eq(0)
        expect(result[:total_solved_all_time]).to eq(1)
      end
    end
  end
end
