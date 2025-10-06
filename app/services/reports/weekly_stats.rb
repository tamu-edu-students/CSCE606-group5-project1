# Module for report generation services
module Reports
  # Service class for generating weekly statistics reports for users
  # Calculates various metrics about user's LeetCode problem solving activity
  class WeeklyStats
    # Difficulty ranking for determining hardest problems (higher number = harder)
    DIFFICULTY_ORDER = { "Hard" => 3, "Medium" => 2, "Easy" => 1 }.freeze

    # Initialize weekly stats calculator for a user
    # @param user [User] The user to generate stats for
    # @param week_start [Time, nil] Start of week to analyze (defaults to current week starting Sunday)
    def initialize(user, week_start: nil)
      @user = user
      @week_start = week_start || Time.zone.now.beginning_of_week(:sunday)  # Default to current week
      @week_end = @week_start.end_of_week(:sunday)                          # End of the same week
    end

    # Generate complete weekly statistics report
    # @return [Hash] Hash containing all calculated statistics
    def call
      {
        weekly_solved_count: weekly_solved_count,      # Problems solved this week
        current_streak_days: current_streak_days,      # Longest consecutive solving streak this week
        total_solved_all_time: total_solved_all_time,  # Total problems solved ever
        highlight: highlight                           # Notable achievements and highlights
      }
    end

    private

    # Get all solved problems for the user (memoized for performance)
    # @return [ActiveRecord::Relation] Relation of solved LeetCodeSessionProblem records
    def solved_problems
      @solved_problems ||= LeetCodeSessionProblem
        .joins(:leet_code_session, :leet_code_problem)                    # Join related tables
        .where(leet_code_sessions: { user_id: @user.id }, solved: true)   # Filter by user and solved status
        .includes(:leet_code_problem)                                     # Eager load problem details
    end

    # Get solved problems within the current week
    # @return [ActiveRecord::Relation] Relation of problems solved this week
    def weekly_solved_problems
      solved_problems.where(solved_at: @week_start..@week_end)
    end

    # Count of problems solved this week
    # @return [Integer] Number of problems solved in the current week
    def weekly_solved_count
      weekly_solved_problems.count
    end

    # Total count of all problems solved by the user
    # @return [Integer] Total number of problems solved across all time
    def total_solved_all_time
      solved_problems.count
    end

    # Calculate the longest consecutive days with problem solving activity this week
    # @return [Integer] Maximum number of consecutive days with at least one solved problem
    def current_streak_days
      # Extract unique dates when problems were solved, sorted chronologically
      dates = weekly_solved_problems.map { |sp| sp.solved_at.to_date }.uniq.sort

      return 0 if dates.empty?  # No problems solved this week

      # Initialize streak counters
      max_streak = 1      # Maximum streak found
      current_streak = 1  # Current streak being counted

      # Iterate through dates to find consecutive sequences
      (1...dates.length).each do |i|
        if dates[i] == dates[i-1] + 1  # Consecutive day found
          current_streak += 1
          max_streak = [ max_streak, current_streak ].max  # Update max if current is longer
        else
          current_streak = 1  # Reset streak counter for non-consecutive day
        end
      end

      max_streak
    end

    # Generate highlight text with notable achievements and accomplishments
    # @return [String] Formatted string with user highlights
    def highlight
      highlights = []

      # Add historical longest streak if available
      if @user.longest_streak.present? && @user.longest_streak > 0
        highlights << "Longest streak: #{@user.longest_streak} days"
      end

      # Find and highlight the hardest problem solved this week
      hardest_this_week = weekly_solved_problems
        .map(&:leet_code_problem)                                    # Get the actual problem objects
        .max_by { |p| DIFFICULTY_ORDER[p.difficulty] || 0 }         # Find hardest by difficulty ranking

      if hardest_this_week
        highlights << "Hardest problem this week: #{hardest_this_week.title} (#{hardest_this_week.difficulty.downcase})"
      end

      # Join all highlights with semicolon separator
      highlights.join("; ")
    end
  end
end
