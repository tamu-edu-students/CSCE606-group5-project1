# frozen_string_literal: true

class StatisticsController < ApplicationController
  before_action :authenticate_user!

  def show
    if current_user.leetcode_username.present?
      fetcher = Leetcode::FetchStats.new
      username = current_user.leetcode_username

      begin
        @stats = fetcher.solved(username)
        @calendar = fetcher.calendar(username)
        @recent_stats = calculate_recent_stats(@calendar)
      rescue => e
        @error_message = "Unable to fetch LeetCode stats: #{e.message}"
        @stats = { total: 0, easy: 0, medium: 0, hard: 0 }
        @recent_stats = { week: 0, month: 0 }
      end
    else
      @stats = { total: 0, easy: 0, medium: 0, hard: 0 }
      @recent_stats = { week: 0, month: 0 }
    end
  end

  private

  def calculate_recent_stats(calendar_data)
    return { week: 0, month: 0 } unless calendar_data && calendar_data['submissionCalendar']

    submissions = calendar_data['submissionCalendar']
    now = Time.current

    # Calculate last 7 days
    week_start = (now - 7.days).beginning_of_day
    week_count = submissions.count do |timestamp, count|
      Time.at(timestamp.to_i) >= week_start
    end

    # Calculate last 30 days
    month_start = (now - 30.days).beginning_of_day
    month_count = submissions.count do |timestamp, count|
      Time.at(timestamp.to_i) >= month_start
    end

    { week: week_count, month: month_count }
  end
end
