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
  rescue => e
    flash[:alert] = "Failed to add problem to session: #{e.message}"
    redirect_to leetcode_path
  end

  private

  def update_google_calendar_event(session, problem)
    service = initialize_google_calendar_service_for(current_user)
    return unless service

    calendar_id = 'primary'
    event_id = session.google_event_id

    event = service.get_event(calendar_id, event_id)

    new_description = [event.description, "", "Leetcode problem added:", "- #{problem.title}", "- #{problem.url}"].compact.join("\n")

    event.description = new_description

    service.update_event(calendar_id, event_id, event)
  rescue => e
    Rails.logger.error("Failed to update Google Calendar event: #{e.message}")
  end

  def initialize_google_calendar_service_for(user)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = 'Leet Planner'

    if user.google_access_token.present?
      service.authorization = Signet::OAuth2::Client.new(access_token: user.google_access_token)
      service
    else
      Rails.logger.error("Google access token missing for user #{user.id}")
      nil
    end
  end
end
