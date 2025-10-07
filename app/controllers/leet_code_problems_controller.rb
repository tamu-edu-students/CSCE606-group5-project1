# Controller for displaying and filtering LeetCode problems
# Provides browsing functionality with difficulty and tag-based filtering
class LeetCodeProblemsController < ApplicationController
  # GET /leetcode
  # Display paginated list of LeetCode problems with optional filtering
  def index
    begin
      # Extract all available tags from problems for filter dropdown
      # Split comma-separated tags, clean whitespace, remove duplicates, and sort
      @available_tags = LeetCodeProblem.pluck(:tags).compact
                              .flat_map { |t| t.split(",") }  # Split comma-separated tags
                              .map(&:strip)                   # Remove whitespace
                              .uniq                          # Remove duplicates
                              .sort                          # Sort alphabetically

      # Start with all problems
      @events = LeetCodeProblem.all

      # Filter by difficulty level if specified
      if params[:difficulty].present?
        @events = @events.where("LOWER(difficulty) = ?", params[:difficulty].downcase)
      end

      # Filter by tags if specified
      if params[:tags].present?
        # Handle both array and comma-separated string formats
        selected_tags = params[:tags].is_a?(Array) ? params[:tags] : params[:tags].split(",")
        selected_tags.map!(&:strip)  # Clean whitespace from each tag

        # Apply each tag filter (AND logic - problem must have all selected tags)
        selected_tags.each do |tag|
          @events = @events.where("tags ILIKE ?", "%#{tag}%")  # Case-insensitive partial match
        end
      end

      # Apply pagination (10 problems per page)
      @events = @events.page(params[:page]).per(10)

    rescue => e
      # Handle any errors gracefully
      Rails.logger.error("Leetcode error: #{e.message}")
      flash.now[:alert] = "Failed to load leet problems."
      @events = []  # Return empty array to prevent view errors
      @available_tags = []
    end
  end
end
