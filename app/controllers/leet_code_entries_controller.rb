class LeetCodeEntriesController < ApplicationController
  def index
    @entries = LeetCodeEntry.today.recent_first
  end

  def new
    @entry = LeetCodeEntry.new(solved_on: Date.current)
  end

  def create
    problem_number = params[:leet_code_entry][:problem_number].to_i
    details = LeetCodeEntry.fetch_problem_details(problem_number)

    if details
      entry_params = params.require(:leet_code_entry).permit(:problem_number, :difficulty, :solved_on)
      entry_params[:problem_title] = details[:title]
      entry_params[:difficulty] = details[:difficulty] if entry_params[:difficulty].blank?
      @entry = LeetCodeEntry.new(entry_params)
    else
      @entry = LeetCodeEntry.new(entry_params)
      @entry.errors.add(:problem_number, "Invalid problem number or unable to fetch details")
    end

    if @entry.save
      flash[:notice] = "LeetCode entry created!"
      redirect_to leet_code_entries_path
    else
      flash.now[:alert] = @entry.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def entry_params
    params.require(:leet_code_entry).permit(:problem_number, :difficulty, :solved_on)
  end
end
