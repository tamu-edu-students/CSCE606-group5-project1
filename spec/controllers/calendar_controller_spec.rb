require 'rails_helper'

RSpec.describe CalendarController, type: :controller do
  let(:user) { create(:user) }
  let(:service_double) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:signet_client_double) { instance_double(Signet::OAuth2::Client) }

  before do
    session[:user_id] = user.id
    # Mock the service instantiation chain
    allow(Signet::OAuth2::Client).to receive(:new).and_return(signet_client_double)
    allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(service_double)
    allow(service_double).to receive(:authorization=)
  end

  describe 'GET #show' do
    context 'when user is not authenticated with Google' do
        it 'redirects to the Google login path' do
            user.update(google_access_token: nil)

            get :show
            expect(response).to redirect_to(login_google_path)
        end
    end

    context 'when user token is expired and refresh fails' do
        before do
            user.update(google_access_token: 'stale', google_token_expires_at: Time.current - 1.hour)
            allow(signet_client_double).to receive(:refresh!).and_raise(Signet::AuthorizationError.new('Refresh failed'))
        end

        it 'redirects to login with an alert' do
            get :show
            expect(response).to redirect_to(login_google_path)
            expect(flash.now[:alert]).to eq("Not authenticated with Google. Please log in.")
        end
    end

    context 'when user is authenticated' do
      before do
        user.update(google_access_token: 'valid', google_token_expires_at: Time.current + 1.hour)
      end

      it 'fetches and maps events successfully' do
        event_item = instance_double(Google::Apis::CalendarV3::Event,
          id: '123', summary: 'Test Event',
          start: double('start', date_time: Time.current, date: nil),
          end: double('end', date_time: Time.current + 1.hour, date: nil)
        )
        response_items = double('response_items', items: [ event_item ])
        allow(service_double).to receive(:list_events).and_return(response_items)

        get :show
        expect(assigns(:events).first[:summary]).to eq('Test Event')
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'POST #sync' do
    let(:sync_result) { { success: true, synced: 5, updated: 2, deleted: 1 } }
    before do
      allow(GoogleCalendarSync).to receive(:sync_for_user).and_return(sync_result)
      # for redirect_back
      request.env['HTTP_REFERER'] = calendar_path
    end

    it 'calls the sync service and sets a notice on success' do
      post :sync
      expect(flash[:notice]).to match(/Calendar synced successfully!/)
      expect(response).to redirect_to(calendar_path)
    end

    it 'sets an alert on failure' do
      allow(GoogleCalendarSync).to receive(:sync_for_user).and_return({ success: false, error: 'API limit reached' })
      post :sync
      expect(flash[:alert]).to eq('Sync failed: API limit reached')
    end
  end

  describe 'GET #edit' do
    let(:event_id) { 'event123' }

    before do
      user.update(google_access_token: 'valid', google_token_expires_at: Time.current + 1.hour)
    end
    it 'fetches an event and assigns it for the view' do
      google_event = instance_double(Google::Apis::CalendarV3::Event,
        id: event_id, summary: 'Editable Event', description: 'Details', location: 'Office',
        start: double('start', date_time: Time.current, date: nil),
        end: double('end', date_time: Time.current + 1.hour, date: nil)
      )
      allow(service_double).to receive(:get_event).with('primary', event_id).and_return(google_event)

      get :edit, params: { id: event_id }
      expect(assigns(:event)[:summary]).to eq('Editable Event')
      expect(response).to render_template(:edit)
    end
  end
end
