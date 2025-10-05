module Reports
  class WeeklyStats
    DIFFICULTY_ORDER = { "Hard" => 3, "Medium" => 2, "Easy" => 1 }.freeze

    def initialize(user, week_start: nil)
      @user = user
      @week_start = week_start || Time.zone.now.beginning_of_week(:sunday)
      @week_end = @week_start.end_of_week(:sunday)
    end

    def call
      {
        weekly_solved_count: weekly_solved_count,
        current_streak_days: current_streak_days,
        total_solved_all_time: total_solved_all_time,
        highlight: highlight
      }
    end

    private

    def solved_problems
      @solved_problems ||= LeetCodeSessionProblem
        .joins(:leet_code_session, :leet_code_problem)
        .where(leet_code_sessions: { user_id: @user.id }, solved: true)
        .includes(:leet_code_problem)
    end

    def weekly_solved_problems
      solved_problems.where(solved_at: @week_start..@week_end)
    end

    def weekly_solved_count
      weekly_solved_problems.count
    end

    def total_solved_all_time
      solved_problems.count
    end

    def current_streak_days
      # Calculate the longest consecutive days with at least one solved problem in the week
      dates = weekly_solved_problems.map { |sp| sp.solved_at.to_date }.uniq.sort

      return 0 if dates.empty?

      max_streak = 1
      current_streak = 1

      (1...dates.length).each do |i|
        if dates[i] == dates[i-1] + 1
          current_streak += 1
          max_streak = [ max_streak, current_streak ].max
        else
          current_streak = 1
        end
      end

      max_streak
    end

    def highlight
      highlights = []

      # Longest streak historically
      if @user.longest_streak.present? && @user.longest_streak > 0
        highlights << "Longest streak: #{@user.longest_streak} days"
      end

      # Hardest problem solved this week
      hardest_this_week = weekly_solved_problems
        .map(&:leet_code_problem)
        .max_by { |p| DIFFICULTY_ORDER[p.difficulty] || 0 }

      if hardest_this_week
        highlights << "Hardest problem this week: #{hardest_this_week.title} (#{hardest_this_week.difficulty.downcase})"
      end

      highlights.join("; ")
    end
  end
end
