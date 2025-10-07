require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user, email: 'other@example.com') }

  # Tests for unauthenticated users
  describe 'authentication requirements' do
    before do
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive(:authenticate_user!).and_call_original
      session[:user_id] = nil
    end

    it 'redirects to login page for protected actions' do
      get :profile
      expect(response).to redirect_to(root_path)

      patch :profile, params: { user: { first_name: 'Test' } }
      expect(response).to redirect_to(root_path)

      get :show, params: { id: user.to_param }
      expect(response).to redirect_to(root_path)

      patch :update, params: { id: user.to_param, user: { first_name: 'Test' } }
      expect(response).to redirect_to(root_path)
    end

    it 'sets flash alert for unauthenticated access' do
      get :profile
      expect(flash[:alert]).to eq('You must be logged in to access this page.')
    end
  end

  # Tests for authenticated users
  context 'when user is authenticated' do
    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:authenticate_user!).and_return(true)
      session[:user_id] = user.id
    end

    # Tests profile viewing functionality
    describe 'GET #profile' do
      it 'renders the profile template' do
        get :profile
        expect(response).to render_template(:profile)
      end

      it 'returns successful response' do
        get :profile
        expect(response).to have_http_status(:success)
      end
    end

    # Tests profile updating functionality
    describe 'PATCH #profile' do
      context 'with valid parameters' do
        let(:valid_params) { { user: { leetcode_username: 'new_username' } } }

        it 'updates the current user and redirects to profile' do
          patch :profile, params: valid_params
          expect(user.reload.leetcode_username).to eq('new_username')
          expect(response).to redirect_to(profile_path)
          expect(flash[:notice]).to eq('Profile updated successfully')
        end
      end

      context 'with invalid parameters' do
        before { allow_any_instance_of(User).to receive(:update).and_return(false) }

        it 're-renders the profile template with unprocessable_entity status' do
          patch :profile, params: { user: { leetcode_username: '' } }
          expect(response).to render_template(:profile)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'with missing user parameter' do
        it 'raises ParameterMissing error' do
          expect { patch :profile, params: {} }.to raise_error(ActionController::ParameterMissing, /user/)
        end
      end
    end

    # Tests individual user viewing functionality
    describe 'GET #show' do
      it 'assigns the requested user and renders the show template' do
        get :show, params: { id: user.to_param }
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template(:show)
        expect(response).to have_http_status(:success)
      end

      it 'raises ActiveRecord::RecordNotFound for non-existent user' do
        expect { get :show, params: { id: 'nonexistent' } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    # Tests user updating functionality
    describe 'PATCH #update' do
      context 'with valid params' do
        let(:new_attributes) { { first_name: 'Jane', leetcode_username: 'janesmith123' } }

        it 'updates the user and redirects to the user page' do
          patch :update, params: { id: user.to_param, user: new_attributes }
          user.reload
          expect(user.first_name).to eq('Jane')
          expect(user.leetcode_username).to eq('janesmith123')
          expect(response).to redirect_to(user)
          expect(flash[:notice]).to eq('User was successfully updated.')
        end
      end

      context 'with invalid params' do
        before { allow_any_instance_of(User).to receive(:update).and_return(false) }

        it 'does not update the user and re-renders the edit template' do
          patch :update, params: { id: user.to_param, user: { first_name: '' } }
          expect(response).to render_template(:edit)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'with missing user parameter' do
        it 'raises ParameterMissing error' do
          expect { patch :update, params: { id: user.to_param } }.to raise_error(ActionController::ParameterMissing, /user/)
        end
      end
    end
  end
end
