require "rails_helper"

# Tests User model validations, attributes, and methods
RSpec.describe User, type: :model do
  # Tests that user can be created with minimum required fields
  it "is valid with required attributes" do
    user = User.new(netid: "test123", email: "test@example.com", first_name: "John", last_name: "Doe")
    expect(user).to be_valid
  end

  # Tests that leetcode_username attribute can be set and retrieved
  it "has leetcode_username attribute" do
    user = User.new(netid: "test123", email: "test@example.com", first_name: "John", last_name: "Doe", leetcode_username: "john123")
    expect(user.leetcode_username).to eq("john123")
  end

  # Tests the full_name instance method functionality
  describe "#full_name" do
    # Tests that full_name concatenates first and last name correctly
    it "returns first and last name" do
      user = User.new(first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end
end
