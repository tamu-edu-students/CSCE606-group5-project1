# Base controller class for the entire application
# Handles authentication, CSRF protection, and browser compatibility
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Protect against Cross-Site Request Forgery (CSRF) attacks
  protect_from_forgery with: :exception

  # Ensure user authentication before any action
  before_action :authenticate_user!

  protected

  # Custom authentication method to check if user is logged in
  # Handles both AJAX/JSON requests and regular HTTP requests differently
  def authenticate_user!
    unless current_user
      if request.xhr? || request.format.json?
        # For AJAX/JSON requests, return JSON error response
        render json: { error: "Authentication required" }, status: :unauthorized
      else
        # For regular requests, redirect to home page
        redirect_to root_path
      end
    end
  end

  # Get the currently logged-in user from session
  # Uses memoization to avoid multiple database queries
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # Make current_user method available in views
  helper_method :current_user

  # Check if a user is currently signed in
  def user_signed_in?
    current_user.present?
  end

  # Make user_signed_in? method available in views
  helper_method :user_signed_in?
end
