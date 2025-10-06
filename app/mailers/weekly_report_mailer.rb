# Mailer for sending weekly progress reports to users
# Sends personalized emails with LeetCode statistics and progress summaries
class WeeklyReportMailer < ApplicationMailer
  
  # Send weekly summary email to user with their coding statistics
  # @param user [User] The user to send the report to
  # @param stats [Hash] Hash containing weekly statistics data
  def summary(user, stats)
    # Set instance variables for use in email template
    @user = user    # User object for personalization
    @stats = stats  # Statistics data to display in email

    # Send email to user's personal email address
    mail(
      to: @user.personal_email,  # Send to user's personal email (not institutional)
      subject: "🌟 Weekly LeetCode Report — #{user.first_name}'s Progress Summary"  # Personalized subject line
    )
  end
end
