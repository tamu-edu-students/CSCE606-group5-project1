require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with required attributes" do
    user = User.new(netid: "test123", email: "test@example.com", first_name: "John", last_name: "Doe")
    expect(user).to be_valid
  end

  it "has leetcode_username attribute" do
    user = User.new(netid: "test123", email: "test@example.com", first_name: "John", last_name: "Doe", leetcode_username: "john123")
    expect(user.leetcode_username).to eq("john123")
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = User.new(first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end
end
