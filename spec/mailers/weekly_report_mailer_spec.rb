require "rails_helper"

# Tests WeeklyReportMailer for sending personalized progress emails to users
RSpec.describe WeeklyReportMailer, type: :mailer do
  let(:user) { User.create!(netid: "john", first_name: "John", last_name: "Doe", email: "john@example.com", personal_email: "john@example.com") }
  let(:stats) do
    {
      weekly_solved_count: 5,
      current_streak_days: 3,
      total_solved_all_time: 25,
      highlight: "Longest streak: 7 days; Hardest problem this week: Two Sum (hard)"
    }
  end

  # Tests weekly summary email generation and content
  describe "#summary" do
    let(:mail) { described_class.summary(user, stats) }

    # Tests that email headers are set correctly with personalized subject
    it "renders the headers" do
      expect(mail.subject).to eq("🌟 Weekly LeetCode Report — John's Progress Summary")
      expect(mail.to).to eq([ user.personal_email ])
      # Note: from address depends on MAIL_FROM env var, but we test the core functionality
    end

    # Tests that email body contains all expected statistics and personalization
    it "renders the body" do
      expect(mail.body.encoded).to include("Hello John")
      expect(mail.body.encoded).to include("Problems Solved This Week: 5")
      expect(mail.body.encoded).to include("Current Streak: 3 days")
      expect(mail.body.encoded).to include("Total Problems Solved: 25")
      expect(mail.body.encoded).to include("Longest streak: 7 days")
      expect(mail.body.encoded).to include("Hardest problem this week: Two Sum (hard)")
    end

    # Tests that email includes both HTML and text versions for compatibility
    it "includes both html and text parts" do
      expect(mail.html_part).to be_present
      expect(mail.text_part).to be_present
    end
  end
end
