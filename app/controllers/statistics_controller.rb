class StatisticsController < ApplicationController
  before_action :authenticate_user!

  def show
    return unless session[:google_token]
    @stats = Reports::WeeklyStats.new(current_user).call
  end
end