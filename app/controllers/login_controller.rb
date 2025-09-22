class LoginController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    if current_user
      redirect_to dashboard_path
    else
      render :index
    end
  end
end
