# Controller for handling user authentication sessions
# Manages Google OAuth login, logout, and session management
class SessionsController < ApplicationController
  # Skip authentication requirement for session management actions
  skip_before_action :authenticate_user!
  # Include Google Calendar auto-sync functionality
  include GoogleCalendarAutoSync

  # GET /debug (development helper)
  # Display current session data for debugging purposes
  def debug
    render plain: session.to_hash.inspect
  end

  # POST /auth/google_oauth2/callback
  # Handle successful Google OAuth callback and create user session
  def create
    # Extract authentication data from OmniAuth
    auth = request.env["omniauth.auth"] || {}
    return redirect_to(root_path, alert: "No auth returned from Google") if auth.blank?

    # Extract user information from OAuth response
    info = auth["info"] || {}
    credentials = auth["credentials"] || {}

    email = info["email"]
    first = info["first_name"]
    last  = info["last_name"]

    # Enforce TAMU domain restrictions for email addresses
    allowed = (ENV["ALLOWED_EMAIL_DOMAINS"] || "").split(",").map(&:strip).map(&:downcase)
    domain  = (email || "").split("@").last.to_s.downcase
    unless email.present? && allowed.include?(domain)
      redirect_to root_path, alert: "Login restricted to TAMU emails" and return
    end

    # Extract NetID from email address
    netid = email.split("@").first

    # Find existing user or create new one
    user = User.find_or_initialize_by(email: email)
    user.netid          ||= netid  # Only set if not already present
    user.email           = email
    user.first_name      = first
    user.last_name       = last
    user.last_login_at   = Time.current

    # Save Google OAuth tokens for API access
    user.google_access_token = credentials["token"]

    # Only overwrite refresh token if present (Google only sends it sometimes)
    if credentials["refresh_token"].present?
      user.google_refresh_token = credentials["refresh_token"]
    end

    # Save token expiry time if provided
    if credentials["expires_at"].present?
      user.google_token_expires_at = Time.at(credentials["expires_at"])
    end

    user.save!

    # Save user information and tokens in session for quick access
    session[:user_id] = user.id
    session[:user_email] = user.email
    session[:user_first_name] = user.first_name
    session[:google_token] = user.google_access_token
    session[:google_refresh_token] = user.google_refresh_token
    session[:google_token_expires_at] = user.google_token_expires_at

    # Log successful authentication
    Rails.logger.info("Google access token saved for user #{user.id}")
    Rails.logger.info("Google refresh token saved for user #{user.id}")

    # Redirect to dashboard with success message
    redirect_to dashboard_path, notice: "Signed in as #{email}"

  rescue => e
    # Handle any errors during authentication process
    Rails.logger.error("Google login error: #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Login failed."
  end

  # GET /auth/failure
  # Handle OAuth authentication failures
  def failure
    redirect_to root_path, alert: params[:message] || "Login failed"
  end

  # DELETE /logout
  # Handle user logout and session cleanup
  def destroy
    # Clear OAuth tokens from user record
    current_user&.update(
      google_access_token: nil,
      google_refresh_token: nil,
      google_token_expires_at: nil
    )

    # Reset entire session to clear all stored data
    reset_session

    # Respond with appropriate format
    respond_to do |format|
      format.html { redirect_to root_path, notice: "You have been signed out successfully." }
      format.json { render json: { message: "Signed out successfully." }, status: :ok }
    end
  end
end
