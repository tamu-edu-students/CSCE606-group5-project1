class LeetCodeEntriesController < ApplicationController
  def index
    @entries = LeetCodeEntry.today.recent_first
  end

  def new
    @entry = LeetCodeEntry.new(solved_on: Date.current)
  end

  def create
    @entry = LeetCodeEntry.new(entry_params)
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
    params.require(:leet_code_entry).permit(:problem_name, :difficulty, :solved_on)
  end
end
