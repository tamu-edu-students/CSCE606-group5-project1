require "rails_helper"

RSpec.describe "LeetCodeEntries", type: :request do
  it "creates entry and redirects to index with flash" do
    # Mock the API response
    allow(HTTParty).to receive(:get).and_return(double(success?: true, parsed_response: { 'title' => 'Two Sum', 'difficulty' => 'Easy' }))

    post leet_code_entries_path, params: {
      leet_code_entry: { problem_number: 1, difficulty: "easy", solved_on: Date.current }
    }
    expect(response).to redirect_to(leet_code_entries_path)
    follow_redirect!
    expect(response.body).to include("LeetCode entry created!")
    expect(response.body).to include("Two Sum")
  end
end
