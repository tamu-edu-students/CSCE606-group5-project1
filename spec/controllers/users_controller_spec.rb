require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:user) { User.create!(netid: "test123", email: "test@example.com", first_name: "John", last_name: "Doe") }

  before do
    session[:user_id] = user.id
  end

  describe "GET #profile" do
    it "responds successfully" do
      get :profile
      expect(response).to be_successful
    end
  end

  describe "PATCH #profile" do
    it "updates leetcode_username" do
      patch :profile, params: { user: { leetcode_username: "john123" } }
      user.reload
      expect(user.leetcode_username).to eq("john123")
    end

    it "redirects to profile with notice" do
      patch :profile, params: { user: { leetcode_username: "john123" } }
      expect(response).to redirect_to(profile_path)
      expect(flash[:notice]).to eq("Profile updated successfully")
    end
  end
end