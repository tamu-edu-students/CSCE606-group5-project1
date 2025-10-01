require "rails_helper"

RSpec.describe Reports::WeeklyStats do
  let(:user) { User.create!(netid: "test_user", email: "test@example.com", first_name: "Test", last_name: "User", active: true) }
  let(:week_start) { Time.zone.parse("2023-09-24 00:00:00") } # Sunday
  let(:service) { described_class.new(user, week_start: week_start) }

  describe "#call" do
    context "with no solved problems" do
      it "returns zero stats" do
        result = service.call
        expect(result[:weekly_solved_count]).to eq(0)
        expect(result[:current_streak_days]).to eq(0)
        expect(result[:total_solved_all_time]).to eq(0)
        expect(result[:highlight]).to eq("")
      end
    end

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

      it "counts weekly solved problems" do
        result = service.call
        expect(result[:weekly_solved_count]).to eq(1)
      end

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

      it "includes hardest problem in highlight" do
        result = service.call
        expect(result[:highlight]).to include("Hardest problem this week: #{problem.title} (hard)")
      end

      it "includes longest streak in highlight" do
        user.update(longest_streak: 5)
        result = service.call
        expect(result[:highlight]).to include("Longest streak: 5 days")
      end
    end

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

      it "does not count problems outside the week" do
        result = service.call
        expect(result[:weekly_solved_count]).to eq(0)
        expect(result[:total_solved_all_time]).to eq(1)
      end
    end
  end
end
