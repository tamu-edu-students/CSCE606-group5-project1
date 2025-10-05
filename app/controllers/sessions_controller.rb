class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  include GoogleCalendarAutoSync

  def debug
  render plain: session.to_hash.inspect
  end

  def create
    auth = request.env["omniauth.auth"] || {}
    return redirect_to(root_path, alert: "No auth returned from Google") if auth.blank?

    info = auth["info"] || {}
    credentials = auth["credentials"] || {}

    email = info["email"]
    first = info["first_name"]
    last  = info["last_name"]

    # Enforce TAMU domains
    allowed = (ENV["ALLOWED_EMAIL_DOMAINS"] || "").split(",").map(&:strip).map(&:downcase)
    domain  = (email || "").split("@").last.to_s.downcase
    unless email.present? && allowed.include?(domain)
      redirect_to root_path, alert: "Login restricted to TAMU emails" and return
    end

    netid = email.split("@").first

    user = User.find_or_initialize_by(email: email)
    user.netid          ||= netid
    user.email           = email
    user.first_name      = first
    user.last_name       = last
    user.last_login_at   = Time.current

    # Save Google tokens
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

    # Save tokens in session as well (optional)
    session[:user_id] = user.id
    session[:user_email] = user.email
    session[:user_first_name] = user.first_name
    session[:google_token] = user.google_access_token
    session[:google_refresh_token] = user.google_refresh_token
    session[:google_token_expires_at] = user.google_token_expires_at

    Rails.logger.info("Google access token saved for user #{user.id}")
    Rails.logger.info("Google refresh token saved for user #{user.id}")

    redirect_to dashboard_path, notice: "Signed in as #{email}"

  rescue => e
    Rails.logger.error("Google login error: #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Login failed."
  end

  def failure
    redirect_to root_path, alert: params[:message] || "Login failed"
  end

  def destroy
    # Clear OAuth tokens
    current_user&.update(
      google_access_token: nil,
      google_refresh_token: nil,
      google_token_expires_at: nil
    )

    # Reset session
    reset_session
    respond_to do |format|
      format.html { redirect_to root_path, notice: "You have been signed out successfully." }
      format.json { render json: { message: "Signed out successfully." }, status: :ok }
    end
  end
end
