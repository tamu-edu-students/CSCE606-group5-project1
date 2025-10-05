class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "LeetPlanner <postmaster@sandbox6b070e52c6b54f729bdadf263ae5111.mailgun.org>")
  layout "mailer"
end
