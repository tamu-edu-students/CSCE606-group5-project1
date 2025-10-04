require "rails_helper"
require "rake"
Rails.application.load_tasks

RSpec.describe "weekly_report:send", type: :task do
  let(:task) { Rake::Task["weekly_report:send"] }

  before do
    task.reenable
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
    ENV["FORCE_SEND"] = "true"
  end

  after do
    ENV.delete("FORCE_SEND")
  end

  context "with active users with emails" do
    let!(:session) { LeetCodeSession.create!(user: active_user, scheduled_time: Time.zone.now, duration_minutes: 60) }
    let!(:problem) { LeetCodeProblem.create!(leetcode_id: "1", title: "Test Problem", difficulty: "easy") }
    let!(:solved_problem) do
      LeetCodeSessionProblem.create!(
        leet_code_session: session,
        leet_code_problem: problem,
        solved: true,
        solved_at: Time.zone.now.beginning_of_week(:sunday) + 1.day
      )
    end
    let!(:active_user) { User.create!(netid: "active", active: true, email: "active@example.com", first_name: "Active", last_name: "User") }
    let!(:inactive_user) { User.create!(netid: "inactive", active: false, email: "inactive@example.com", first_name: "Inactive", last_name: "User") }

    it "sends emails only to active users with emails who have weekly solves" do
      expect(WeeklyReportMailer).to receive(:summary).with(active_user, anything).and_call_original
      expect(WeeklyReportMailer).not_to receive(:summary).with(inactive_user, anything)

      task.invoke
    end

    it "logs the process" do
      allow(WeeklyReportMailer).to receive_message_chain(:summary, :deliver_now)

      task.invoke

      expect(Rails.logger).to have_received(:info).with("Starting weekly report email task")
      expect(Rails.logger).to have_received(:info).with("Found 1 eligible users")
      expect(Rails.logger).to have_received(:info).with("Sent weekly report to active@example.com")
      expect(Rails.logger).to have_received(:info).with("Completed weekly report email task")
    end

    it "handles errors gracefully" do
      allow(WeeklyReportMailer).to receive(:summary).and_raise(StandardError.new("Email failed"))

      expect { task.invoke }.not_to raise_error

      expect(Rails.logger).to have_received(:error).with("Failed to send weekly report to active@example.com: Email failed")
    end
  end
end
