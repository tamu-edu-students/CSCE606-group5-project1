require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:user) }
  before do
    session[:user_id] = user.id
  end

  describe 'GET #show' do
    context 'without a google token in session' do
      it 'renders successfully without an event' do
        get :show
        expect(response).to have_http_status(:success)
        expect(assigns(:current_event)).to be_nil
      end
    end

    context 'with a google token in session' do
      let(:google_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }

      before do
        session[:user_id] = user.id
        session[:google_token] = 'fake-token'
        allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(google_service)
        allow(google_service).to receive(:authorization=)
      end

      context 'when an event is currently active' do
        it 'assigns the current event and remaining time' do
            travel_to Time.current do # Freezes time for this block
            now = Time.current.utc
            active_event = instance_double(Google::Apis::CalendarV3::Event,
                start: double('start', date_time: now - 30.minutes, date: nil),
                end: double('end', date_time: now + 30.minutes, date: nil)
            )
            response_items = double('response_items', items: [ active_event ])
            allow(google_service).to receive(:list_events).and_return(response_items)

            get :show

            expect(assigns(:current_event)).to eq(active_event)
            expect(assigns(:time_remaining_hms)).to eq("00:30:00")
            end
        end
      end

      context 'when no event is active but a custom timer is running' do
        let(:response_items) { double('response_items', items: []) }
        before do
          allow(google_service).to receive(:list_events).and_return(response_items)
          session[:timer_ends_at] = (Time.current + 15.minutes).iso8601
        end
        it 'calculates the remaining time for the custom timer' do
          get :show
          expect(assigns(:current_event)).to be_nil
          expect(assigns(:time_remaining_hms)).to match(/00:14:\d{2}|00:15:00/)
        end
      end
    end
  end

  describe 'POST #create_timer' do
    it 'sets the timer in the session for valid minutes' do
      post :create_timer, params: { minutes: '25' }
      expect(session[:timer_ends_at]).to be_present
    end

    it 'does not set the timer for invalid minutes' do
      post :create_timer, params: { minutes: '0' }
      expect(session[:timer_ends_at]).to be_nil
    end

    it 'redirects to the dashboard' do
      post :create_timer, params: { minutes: '10' }
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
