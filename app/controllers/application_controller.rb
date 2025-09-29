class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  protected

  def authenticate_user!
    unless current_user
      if request.xhr? || request.format.json?
        render json: { error: "Authentication required" }, status: :unauthorized
      else
        redirect_to root_path
      end
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def user_signed_in?
    current_user.present?
  end
  # --- ADMIN GATE ---
  def require_admin!
    authenticate_user!          # reuse your existing login check
    return if performed?        # if authenticate_user! already redirected/rendered

    unless current_user&.role == "admin"
      if request.xhr? || request.format.json?
        render json: { error: "Not authorized" }, status: :forbidden
      else
        redirect_to root_path, alert: "Not authorized"
      end
    end
  end

  def admin?
    current_user&.role == "admin"
  end
  helper_method :admin?
  helper_method :user_signed_in?
end
