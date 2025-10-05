# frozen_string_literal: true

class StatisticsController < ApplicationController
  before_action :authenticate_user!

  def show
    @weekly_stats = Reports::WeeklyStats.new(current_user).call

    # For backward compatibility with the view
    @stats = {
      total: @weekly_stats[:total_solved_all_time],
      easy: 0, # We don't track difficulty breakdown in our local stats
      medium: 0,
      hard: 0
    }
    @recent_stats = {
      week: @weekly_stats[:weekly_solved_count],
      month: 0 # We don't calculate monthly stats in WeeklyStats
    }
  end
end
