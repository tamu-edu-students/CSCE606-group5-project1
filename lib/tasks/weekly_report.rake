namespace :weekly_report do
  desc "Send weekly progress summary emails to active users with email addresses"
  task send: :environment do
    Rails.logger.info "Starting weekly report email task"

    week_start = ENV["WEEK_START"] ? Time.zone.parse(ENV["WEEK_START"]) : nil

    users = User.active.with_email

    Rails.logger.info "Found #{users.count} eligible users"

    users.find_each do |user|
      begin
        stats = Reports::WeeklyStats.new(user, week_start: week_start).call
        mail = WeeklyReportMailer.summary(user, stats)
        if Rails.env.production?
          mail.deliver_later
        else
          mail.deliver_now
        end
        Rails.logger.info "Sent weekly report to #{user.email}"
      rescue => e
        Rails.logger.error "Failed to send weekly report to #{user.email}: #{e.message}"
      end
    end

    Rails.logger.info "Completed weekly report email task"
  end
end
