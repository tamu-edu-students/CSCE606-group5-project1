# Base class for all mailers in the application
# Inherits from ActionMailer::Base and provides common configuration for all email sending
class ApplicationMailer < ActionMailer::Base
  # Set default sender email address from environment variable or fallback to Mailgun sandbox
  default from: ENV.fetch("MAIL_FROM", "LeetPlanner <postmaster@sandbox6b070e52c6b54f729bdadf263ae5111.mailgun.org>")
  
  # Use the mailer layout template for all emails
  layout "mailer"
end
