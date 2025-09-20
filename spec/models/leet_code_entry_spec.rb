require "rails_helper"

RSpec.describe LeetCodeEntry, type: :model do
  it "is valid with name and difficulty" do
    e = LeetCodeEntry.new(problem_name: "Two Sum", difficulty: :easy, solved_on: Date.current)
    expect(e).to be_valid
  end

  it "invalid without problem_name" do
    e = LeetCodeEntry.new(difficulty: :easy, solved_on: Date.current)
    expect(e).not_to be_valid
  end

  it "invalid without difficulty" do
    e = LeetCodeEntry.new(problem_name: "Two Sum", solved_on: Date.current)
    expect(e).not_to be_valid
  end

  it "enum works" do
    e = LeetCodeEntry.create!(problem_name: "Two Sum", difficulty: :medium, solved_on: Date.current)
    expect(e.medium?).to be true
  end
end
