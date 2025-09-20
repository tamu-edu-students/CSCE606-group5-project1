require "rails_helper"

RSpec.describe "LeetCodeEntries", type: :request do
  it "creates entry and redirects to index with flash" do
    post leet_code_entries_path, params: {
      leet_code_entry: { problem_name: "Two Sum", difficulty: "easy", solved_on: Date.current }
    }
    expect(response).to redirect_to(leet_code_entries_path)
    follow_redirect!
    expect(response.body).to include("LeetCode entry created!")
    expect(response.body).to include("Two Sum")
  end
end
