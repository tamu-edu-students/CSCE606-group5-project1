require "googleauth"

class LeetCodeSessionsController < ApplicationController
  before_action :authenticate_user!

  def add_problem
    problem = LeetCodeProblem.find(params[:problem_id])
    session = current_user.leet_code_sessions.find(params[:session_id])

    LeetCodeSessionProblem.create!(
      leet_code_session: session,
      leet_code_problem: problem,
      solved: false
    )

    update_google_calendar_event(session, problem)

    flash[:notice] = "#{problem.title} added to session on #{session.scheduled_time.strftime('%F %R')}"
    redirect_to leetcode_path

  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Session or problem not found."
    redirect_to leetcode_path
  rescue StandardError => e
    flash[:alert] = "Failed to add problem to session: #{e.message}"
    redirect_to leetcode_path
  end

  private

  def update_google_calendar_event(session, problem)
    service = initialize_google_calendar_service_for(current_user)
    return unless service && session.google_event_id.present?

    calendar_id = "primary"
    event_id = session.google_event_id

    begin
      event = service.get_event(calendar_id, event_id)

      new_description = [ event.description.to_s,
                         "",
                         "Leetcode problem added:",
                         "- #{problem.title}",
                         "- #{problem.url}" ].join("\n")

      event.description = new_description
      service.update_event(calendar_id, event_id, event)
      Rails.logger.info("Google Calendar event #{event_id} updated for user #{current_user.id}")

    rescue Google::Apis::ClientError => e
      Rails.logger.error("Google API client error while updating event: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("Failed to update Google Calendar event: #{e.message}")
    end
  end

  def initialize_google_calendar_service_for(user)
    return nil unless user.google_access_token.present? && user.google_refresh_token.present?

    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = "Leet Planner"

    credentials = Signet::OAuth2::Client.new(
      client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
      client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
      access_token: user.google_access_token,
      refresh_token: user.google_refresh_token,
      token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
    )

    if credentials.expired?
      begin
        credentials.refresh!
        user.update!(
          google_access_token: credentials.access_token,
          google_refresh_token: credentials.refresh_token || user.google_refresh_token
        )
      rescue StandardError => e
        Rails.logger.error("Failed to refresh Google token for user #{user.id}: #{e.message}")
        return nil
      end
    end

    service.authorization = credentials
    service
  end
end
