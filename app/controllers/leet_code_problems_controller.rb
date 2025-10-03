class LeetCodeProblemsController < ApplicationController
  def show
    begin
      @available_tags = LeetCodeProblem.pluck(:tags).compact
                              .flat_map { |t| t.split(',') }
                              .map(&:strip)
                              .uniq
                              .sort
      @events = LeetCodeProblem.all

      # Filter by solved status
      # if params[:solved].present?
      #   if params[:solved] == 'true'
      #     @events = @events.where.not(description: [nil, '']) # Dummy logic: if description exists, consider it solved
      #   elsif params[:solved] == 'false'
      #     @events = @events.where(description: [nil, ''])
      #   end
      # end

      # Filter by difficulty
      if params[:difficulty].present?
        @events = @events.where("LOWER(difficulty) = ?", params[:difficulty].downcase)
      end


      # Filter by tags
      if params[:tags].present?
        selected_tags = params[:tags].is_a?(Array) ? params[:tags] : params[:tags].split(',')
        selected_tags.map!(&:strip)

        selected_tags.each do |tag|
          @events = @events.where("tags ILIKE ?", "%#{tag}%")
        end
      end

      @events = @events.page(params[:page]).per(10)

    rescue => e
      Rails.logger.error("Leetcode error: #{e.message}")
      flash.now[:alert] = "Failed to load leet problems."
      @events = []
    end
  end
end
