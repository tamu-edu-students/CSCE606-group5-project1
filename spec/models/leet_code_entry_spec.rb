require "rails_helper"

RSpec.describe LeetCodeEntry, type: :model do
  it "is valid with number and difficulty" do
    e = LeetCodeEntry.new(problem_number: 1, problem_title: "Two Sum", difficulty: :easy, solved_on: Date.current)
    expect(e).to be_valid
  end

  it "invalid without problem_number" do
    e = LeetCodeEntry.new(difficulty: :easy, solved_on: Date.current)
    expect(e).not_to be_valid
  end

  it "invalid without difficulty" do
    e = LeetCodeEntry.new(problem_number: 1, solved_on: Date.current)
    expect(e).not_to be_valid
  end

  it "enum works" do
    e = LeetCodeEntry.create!(problem_number: 1, problem_title: "Two Sum", difficulty: :medium, solved_on: Date.current)
    expect(e.medium?).to be true
  end

  describe ".fetch_problem_details" do
    it "fetches problem details from API" do
      # Mock the API response
      allow(HTTParty).to receive(:get).and_return(double(success?: true, parsed_response: { 'title' => 'Two Sum', 'difficulty' => 'Easy' }))

      details = LeetCodeEntry.fetch_problem_details(1)
      expect(details).to eq({ title: 'Two Sum', difficulty: 'easy' })
    end

    it "returns nil on API failure" do
      allow(HTTParty).to receive(:get).and_return(double(success?: false))

      details = LeetCodeEntry.fetch_problem_details(999999)
      expect(details).to be_nil
    end
  end
end
