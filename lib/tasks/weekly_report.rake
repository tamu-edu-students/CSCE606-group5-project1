namespace :weekly_report do
  desc "Send weekly progress summary emails to active users with personal email addresses"
  task send: :environment do
    # Only run on Mondays
    if Date.today.wday != 1 && ENV["FORCE_SEND"] != "true"
      Rails.logger.info "Not Monday, skipping weekly report task"
      next
    end

    Rails.logger.info "Starting weekly report email task"

    week_start = ENV["WEEK_START"] ? Time.zone.parse(ENV["WEEK_START"]) : nil

    users = User.active.where.not(personal_email: nil)
    Rails.logger.info "Found #{users.count} eligible users"

    users.find_each do |user|
      begin
        stats = Reports::WeeklyStats.new(user, week_start: week_start).call
        if stats[:weekly_solved_count] > 0
          mail = WeeklyReportMailer.summary(user, stats)
          if Rails.env.production?
            mail.deliver_later
          else
            mail.deliver_now
          end
          Rails.logger.info "Sent weekly report to #{user.personal_email}"
        else
          Rails.logger.info "Skipped weekly report for #{user.personal_email} (no solves this week)"
        end
      rescue => e
        Rails.logger.error "Failed to send weekly report to #{user.personal_email}: #{e.message}"
      end
    end

    Rails.logger.info "Completed weekly report email task"
  end
end
