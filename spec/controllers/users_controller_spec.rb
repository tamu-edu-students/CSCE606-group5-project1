require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }

  before do
    # Simulate a logged-in user
    session[:user_id] = user.id
  end

  describe 'GET #profile' do
    it 'renders the profile template' do
      get :profile
      expect(response).to render_template(:profile)
    end
  end

  describe 'PATCH #profile' do
    context 'with valid parameters' do
      it 'updates the current user\'s leetcode_username' do
        patch :profile, params: { user: { leetcode_username: 'new_username' } }
        expect(user.reload.leetcode_username).to eq('new_username')
      end

      it 'redirects to the profile path' do
        patch :profile, params: { user: { leetcode_username: 'new_username' } }
        expect(response).to redirect_to(profile_path)
      end
    end
  end

  describe 'GET #show' do
    it 'assigns the requested user as @user' do
      get :show, params: { id: user.to_param }
      expect(assigns(:user)).to eq(user)
    end

    it 'renders the show template' do
      get :show, params: { id: user.to_param }
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:new_attributes) { { first_name: 'Jane' } }

      it 'updates the requested user' do
        patch :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.first_name).to eq('Jane')
      end

      it 'redirects to the user' do
        patch :update, params: { id: user.to_param, user: new_attributes }
        expect(response).to redirect_to(user)
      end
    end
  end

end
