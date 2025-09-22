class SessionsController < ApplicationController
  def create
    auth = request.env["omniauth.auth"] || {}
    return redirect_to(root_path, alert: "No auth returned from Google") if auth.blank?

    info = auth["info"] || {}

    email      = info["email"]
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
    user.netid         ||= netid
    user.email      = email
    user.first_name = first
    user.last_name  = last
    user.last_login_at = Time.current
    user.save!

    session[:user_id] = user.id
    session[:user_email] = auth["info"]["email"]
    session[:google_token] = auth["credentials"]["token"]
    session[:google_refresh_token] = auth["credentials"]["refresh_token"]
    Rails.logger.info("Google token: #{session[:google_token]}")
    Rails.logger.info("Google refresh token: #{session[:google_refresh_token]}")
    redirect_to calendar_path, notice: "Signed in as #{email}"
    rescue => e
    Rails.logger.error("Google login error: #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Login failed."
  end

  def failure
    redirect_to root_path, alert: params[:message] || "Login failed"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out"
  end
end
