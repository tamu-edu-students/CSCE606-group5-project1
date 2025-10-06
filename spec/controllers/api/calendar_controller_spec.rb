require 'rails_helper'

RSpec.describe Api::CalendarController, type: :controller do
  let(:user) { create(:user) }
  let(:google_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:signet_client) { instance_double(Signet::OAuth2::Client) }

  # This block mocks the entire Google authentication and service chain
  before do
    allow(signet_client).to receive(:refresh!)
    allow(signet_client).to receive(:access_token).and_return('refreshed-access-token')
    allow(signet_client).to receive(:refresh_token).and_return('refreshed-refresh-token')
    allow(signet_client).to receive(:expires_at).and_return(Time.current.to_i + 3600)

    allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(google_service)
    allow(google_service).to receive(:authorization=)
    session[:user_id] = user.id
    
    session[:user_id] = user.id # Simulate a logged-in user
  end

  describe 'authentication filter' do
    context 'when user has no google token in session' do
      it 'redirects to the google login path' do
        post :create, params: { event: { summary: 'Test' } }
        expect(response).to redirect_to(login_google_path)
      end
    end

    context 'when user token is expired and refresh fails' do
      before do
        session[:google_token] = 'stale-token'
        session[:google_token_expires_at] = Time.current.to_i - 3600
        
        # Use allow_any_instance_of to stub refresh! on any instance of the client
        allow_any_instance_of(Signet::OAuth2::Client).to receive(:refresh!).and_raise(Signet::AuthorizationError.new('Refresh failed'))
      end

      it 'resets session and redirects to login' do
        post :create, params: { event: { summary: 'Test' } }
        
        expect(session[:google_token]).to be_nil
        expect(response).to redirect_to(login_google_path)
        expect(flash[:alert]).to match(/Your session expired/)
      end
    end
  end

  # The following tests assume a valid google session
  context 'with a valid google session' do
    before do
      session[:google_token] = 'valid-token'
      session[:google_token_expires_at] = Time.current.to_i + 3600 # Expires in an hour
    end

    describe 'POST #create' do
      context 'with valid parameters' do
        let(:event_params) { { summary: 'New Event', start_date: '2025-10-26', start_time: '14:00' } }
        let(:mock_created_event) { instance_double(Google::Apis::CalendarV3::Event, id: '123', summary: 'New Event', start: double(date_time: '...'), end: double(date_time: '...'), location: nil, description: nil) }

        before do
          allow(google_service).to receive(:insert_event).and_return(mock_created_event)
        end

        it 'redirects to the calendar path for HTML requests' do
          post :create, params: { event: event_params }
          expect(response).to redirect_to(calendar_path)
          expect(flash[:notice]).to eq('Event successfully created.')
        end

        it 'renders JSON for JSON requests' do
          post :create, params: { event: event_params }, format: :json
          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)['summary']).to eq('New Event')
        end
      end

      context 'without an event name' do
        it 'redirects back with an alert' do
          request.env["HTTP_REFERER"] = calendar_path
          post :create, params: { event: { summary: '' } }
          expect(response).to redirect_to(calendar_path)
          expect(flash[:alert]).to eq('Event name is required.')
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:event_id) { 'event_to_delete' }

      it 'calls the delete_event service and redirects' do
        expect(google_service).to receive(:delete_event).with('primary', event_id)
        delete :destroy, params: { id: event_id }
        expect(response).to redirect_to(calendar_path(anchor: 'calendar'))
        expect(flash[:notice]).to eq('Event deleted.')
      end

      it 'handles API errors gracefully' do
        allow(google_service).to receive(:delete_event).and_raise(Google::Apis::ClientError.new('Not found'))
        delete :destroy, params: { id: event_id }
        expect(response).to redirect_to(calendar_path(anchor: 'calendar'))
        expect(flash[:alert]).to eq('Failed to delete event.')
      end
    end
  end
end