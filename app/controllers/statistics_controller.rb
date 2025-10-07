# frozen_string_literal: true

# Controller for displaying user statistics and progress tracking
# Shows LeetCode problem solving statistics and progress over time
class StatisticsController < ApplicationController
  # Ensure user is authenticated before accessing statistics
  before_action :authenticate_user!

  # GET /statistics
  # Display user's coding statistics including weekly and all-time progress
  def show
    # Generate weekly statistics report for the current user
    @weekly_stats = Reports::WeeklyStats.new(current_user).call

    # For backward compatibility with the view
    # Create stats hash with total problems solved (difficulty breakdown not tracked locally)
    @stats = {
      total: @weekly_stats[:total_solved_all_time],  # Total problems solved across all time
      easy: 0,   # We don't track difficulty breakdown in our local stats
      medium: 0, # We don't track difficulty breakdown in our local stats
      hard: 0    # We don't track difficulty breakdown in our local stats
    }

    # Create recent stats hash for time-based progress tracking
    @recent_stats = {
      week: @weekly_stats[:weekly_solved_count],  # Problems solved this week
      month: 0  # We don't calculate monthly stats in WeeklyStats service
    }
  end
end
