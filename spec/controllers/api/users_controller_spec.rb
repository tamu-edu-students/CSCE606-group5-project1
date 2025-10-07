require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  let(:user) { create(:user, first_name: 'John', last_name: 'Doe', email: 'john.doe@tamu.edu') }

  describe 'GET #profile' do
    context 'when user is signed in' do
      before do
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'returns user profile data as JSON' do
        get :profile

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          'id' => user.id,
          'name' => user.full_name,
          'first_name' => user.first_name,
          'email' => user.email
        )
      end

      it 'includes all required fields in response' do
        get :profile

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('id')
        expect(json_response).to have_key('name')
        expect(json_response).to have_key('first_name')
        expect(json_response).to have_key('email')
      end

      it 'returns correct user data' do
        get :profile

        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(user.id)
        expect(json_response['name']).to eq('John Doe')
        expect(json_response['first_name']).to eq('John')
        expect(json_response['email']).to eq('john.doe@tamu.edu')
      end
    end

    context 'when user is not signed in' do
      before do
        allow(controller).to receive(:user_signed_in?).and_return(false)
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'redirects unauthenticated users' do
        get :profile

        expect(response).to have_http_status(:found) # 302 redirect
        expect(response).to be_redirect
      end

      it 'redirects to login page' do
        get :profile

        # Update this to match where your app actually redirects
        # Common options: root_path, login_path, new_user_session_path
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when authentication state is inconsistent' do
      before do
        allow(controller).to receive(:user_signed_in?).and_return(true)
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'handles nil current_user when user_signed_in? is true' do
        expect { get :profile }.not_to raise_error

        # This might cause an error or redirect depending on implementation
        expect(response.status).to be_in([ 302, 500 ])
      end
    end
  end
end
