class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth'] || {}
    info = auth['info'] || {}

    provider   = auth['provider']
    uid        = auth['uid']
    email      = info['email']
    first_name = info['first_name']
    last_name  = info['last_name']
    image_url  = info['image']

    # Enforce TAMU domains
    allowed = (ENV['ALLOWED_EMAIL_DOMAINS'] || '').split(',').map(&:strip).map(&:downcase)
    domain  = (email || '').split('@').last.to_s.downcase
    unless email.present? && allowed.include?(domain)
      redirect_to root_path, alert: 'Login restricted to TAMU emails' and return
    end

    user = User.find_or_initialize_by(provider: provider, uid: uid)
    user.update!(email: email, first_name: first_name, last_name: last_name, image_url: image_url)
    session[:user_id] = user.id
    redirect_to root_path, notice: "Signed in as #{email}"
    rescue => e
    Rails.logger.error("Google login error: #{e.class}: #{e.message}")
    redirect_to root_path, alert: 'Login failed'
  end

  def failure
    redirect_to root_path, alert: params[:message] || 'Login failed'
  end

  def destroy
    reset_session
    redirect_to root_path, notice: 'Signed out'
  end
end
