class WeeklyReportMailer < ApplicationMailer
  def summary(user, stats)
    @user = user
    @stats = stats

    mail(
      to: @user.personal_email,
      subject: "🌟 Weekly LeetCode Report — #{user.first_name}'s Progress Summary"
    )
  end
end
