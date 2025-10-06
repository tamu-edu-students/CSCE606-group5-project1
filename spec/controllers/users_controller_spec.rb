require 'rails_helper'

# Tests UsersController functionality including profile management and CRUD operations
RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    # Simulate a logged-in user
    session[:user_id] = user.id
  end

  # Tests profile viewing functionality
  describe 'GET #profile' do
    # Tests that profile page renders correctly
    it 'renders the profile template' do
      get :profile
      expect(response).to render_template(:profile)
    end
  end

  # Tests profile updating functionality
  describe 'PATCH #profile' do
    # Tests successful profile updates
    context 'with valid parameters' do
      # Tests that LeetCode username can be updated via profile
      it 'updates the current user\'s leetcode_username' do
        patch :profile, params: { user: { leetcode_username: 'new_username' } }
        expect(user.reload.leetcode_username).to eq('new_username')
      end

      # Tests redirect behavior after successful profile update
      it 'redirects to the profile path' do
        patch :profile, params: { user: { leetcode_username: 'new_username' } }
        expect(response).to redirect_to(profile_path)
      end
    end
  end

  # Tests individual user viewing functionality
  describe 'GET #show' do
    # Tests that correct user is loaded for display
    it 'assigns the requested user as @user' do
      get :show, params: { id: user.to_param }
      expect(assigns(:user)).to eq(user)
    end

    # Tests that show template renders correctly
    it 'renders the show template' do
      get :show, params: { id: user.to_param }
      expect(response).to render_template(:show)
    end
  end

  # Tests user updating functionality
  describe 'PATCH #update' do
    # Tests successful user updates
    context 'with valid params' do
      let(:new_attributes) { { first_name: 'Jane' } }

      # Tests that user attributes are updated correctly
      it 'updates the requested user' do
        patch :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.first_name).to eq('Jane')
      end

      # Tests redirect behavior after successful update
      it 'redirects to the user' do
        patch :update, params: { id: user.to_param, user: new_attributes }
        expect(response).to redirect_to(user)
      end
    end
  end
end
