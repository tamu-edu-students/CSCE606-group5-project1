require "rails_helper"

RSpec.describe WeeklyReportMailer, type: :mailer do
  let(:user) { User.create!(netid: "john", first_name: "John", last_name: "Doe", email: "john@example.com") }
  let(:stats) do
    {
      weekly_solved_count: 5,
      current_streak_days: 3,
      total_solved_all_time: 25,
      highlight: "Longest streak: 7 days; Hardest problem this week: Two Sum (hard)"
    }
  end

  describe "#summary" do
    let(:mail) { described_class.summary(user, stats) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Weekly LeetCode Progress Summary")
      expect(mail.to).to eq([ user.email ])
      # Note: from address depends on MAIL_FROM env var, but we test the core functionality
    end

    it "renders the body" do
      expect(mail.body.encoded).to include("Hello John")
      expect(mail.body.encoded).to include("Problems Solved This Week: 5")
      expect(mail.body.encoded).to include("Current Streak: 3 days")
      expect(mail.body.encoded).to include("Total Problems Solved: 25")
      expect(mail.body.encoded).to include("Longest streak: 7 days")
      expect(mail.body.encoded).to include("Hardest problem this week: Two Sum (hard)")
    end

    it "includes both html and text parts" do
      expect(mail.html_part).to be_present
      expect(mail.text_part).to be_present
    end
  end
end
