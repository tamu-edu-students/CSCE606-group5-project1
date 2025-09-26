class WeeklyReportMailer < ApplicationMailer
  def summary(user, stats)
    @user = user
    @stats = stats

    mail(
      to: @user.email,
      subject: "Your Weekly LeetCode Progress Summary"
    )
  end
end
