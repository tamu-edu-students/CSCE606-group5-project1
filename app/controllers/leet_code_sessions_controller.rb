# Required for Google OAuth2 authentication
require "googleauth"

# Controller for managing LeetCode coding sessions
# Handles adding problems to sessions and updating Google Calendar events
class LeetCodeSessionsController < ApplicationController
  # Ensure user is authenticated before accessing session management
  before_action :authenticate_user!

  # POST /leet_code_sessions/:session_id/add_problem
  # Add a LeetCode problem to an existing coding session
  def add_problem
    # Find the problem and session from parameters
    problem = LeetCodeProblem.find(params[:problem_id])
    session = current_user.leet_code_sessions.find(params[:session_id])

    # Create association between session and problem
    LeetCodeSessionProblem.create!(
      leet_code_session: session,
      leet_code_problem: problem,
      solved: false  # Initially marked as unsolved
    )

    # Update the corresponding Google Calendar event with problem details
    update_google_calendar_event(session, problem)

    # Redirect with success message
    flash[:notice] = "#{problem.title} added to session on #{session.scheduled_time.strftime('%F %R')}"
    redirect_to leetcode_path

  rescue ActiveRecord::RecordNotFound
    # Handle case where session or problem doesn't exist
    flash[:alert] = "Session or problem not found."
    redirect_to leetcode_path
  rescue StandardError => e
    # Handle any other errors during the process
    flash[:alert] = "Failed to add problem to session: #{e.message}"
    redirect_to leetcode_path
  end

  private

  # Update Google Calendar event description with newly added problem information
  def update_google_calendar_event(session, problem)
    # Get authenticated Google Calendar service
    service = initialize_google_calendar_service_for(current_user)
    return unless service && session.google_event_id.present?

    calendar_id = "primary"
    event_id = session.google_event_id

    begin
      # Fetch the existing calendar event
      event = service.get_event(calendar_id, event_id)

      # Append problem information to event description
      new_description = [ event.description.to_s,
                         "",
                         "Leetcode problem added:",
                         "- #{problem.title}",
                         "- #{problem.url}" ].join("\n")

      # Update event with new description
      event.description = new_description
      service.update_event(calendar_id, event_id, event)
      Rails.logger.info("Google Calendar event #{event_id} updated for user #{current_user.id}")

    rescue Google::Apis::ClientError => e
      # Handle Google API specific errors
      Rails.logger.error("Google API client error while updating event: #{e.message}")
    rescue StandardError => e
      # Handle any other errors during calendar update
      Rails.logger.error("Failed to update Google Calendar event: #{e.message}")
    end
  end

  # Initialize and authenticate Google Calendar service for a specific user
  # Returns nil if user doesn't have required tokens or if authentication fails
  def initialize_google_calendar_service_for(user)
    # Check if user has required Google tokens
    return nil unless user.google_access_token.present? && user.google_refresh_token.present?

    # Create Google Calendar service instance
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = "Leet Planner"

    # Set up OAuth2 credentials
    credentials = Signet::OAuth2::Client.new(
      client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
      client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
      access_token: user.google_access_token,
      refresh_token: user.google_refresh_token,
      token_credential_uri: ENV["GOOGLE_OAUTH_URI"]
    )

    # Refresh token if expired
    if credentials.expired?
      begin
        credentials.refresh!
        # Update user with new token information
        user.update!(
          google_access_token: credentials.access_token,
          google_refresh_token: credentials.refresh_token || user.google_refresh_token
        )
      rescue StandardError => e
        # Log error and return nil if token refresh fails
        Rails.logger.error("Failed to refresh Google token for user #{user.id}: #{e.message}")
        return nil
      end
    end

    # Attach credentials to service and return
    service.authorization = credentials
    service
  end
end
