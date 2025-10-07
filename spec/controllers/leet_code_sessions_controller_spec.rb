require 'rails_helper'
require 'google/apis/calendar_v3'
require 'signet/oauth_2/client'

RSpec.describe LeetCodeSessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:leet_code_session) { create(:leet_code_session, user: user, google_event_id: 'test_event_id') }
  let(:leet_code_problem) { create(:leet_code_problem) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'POST #add_problem' do
    context 'when successfully adding a problem to a session' do
      let(:mock_service) { instance_double('Google::Apis::CalendarV3::CalendarService') }
      let(:mock_event) { instance_double('Google::Apis::CalendarV3::Event', description: 'Original description') }

      before do
        allow(controller).to receive(:initialize_google_calendar_service_for).and_return(mock_service)
        allow(mock_service).to receive(:get_event).and_return(mock_event)
        allow(mock_service).to receive(:update_event).and_return(mock_event)
        allow(mock_event).to receive(:description=)
      end

      it 'creates a new LeetCodeSessionProblem' do
        expect {
          post :add_problem, params: { session_id: leet_code_session.id, problem_id: leet_code_problem.id }
        }.to change(LeetCodeSessionProblem, :count).by(1)
      end

      it 'sets the problem as unsolved initially' do
        post :add_problem, params: { session_id: leet_code_session.id, problem_id: leet_code_problem.id }
        session_problem = LeetCodeSessionProblem.last
        expect(session_problem.solved).to be false
      end

      it 'updates the Google Calendar event' do
        expect(mock_service).to receive(:get_event).with('primary', 'test_event_id')
        expect(mock_service).to receive(:update_event).with('primary', 'test_event_id', mock_event)
        post :add_problem, params: { session_id: leet_code_session.id, problem_id: leet_code_problem.id }
      end

      it 'redirects to leetcode path with success message' do
        post :add_problem, params: { session_id: leet_code_session.id, problem_id: leet_code_problem.id }
        expect(response).to redirect_to(leetcode_path)
        expect(flash[:notice]).to include(leet_code_problem.title)
      end
    end

    context 'when session is not found' do
      it 'redirects with an error message' do
        post :add_problem, params: { session_id: 99999, problem_id: leet_code_problem.id }
        expect(response).to redirect_to(leetcode_path)
        expect(flash[:alert]).to eq('Session or problem not found.')
      end
    end

    context 'when problem is not found' do
      it 'redirects with an error message' do
        post :add_problem, params: { session_id: leet_code_session.id, problem_id: 99999 }
        expect(response).to redirect_to(leetcode_path)
        expect(flash[:alert]).to eq('Session or problem not found.')
      end
    end

    context 'when Google Calendar update fails' do
      before do
        allow(controller).to receive(:initialize_google_calendar_service_for).and_return(nil)
      end

      it 'still creates the session problem' do
        expect {
          post :add_problem, params: { session_id: leet_code_session.id, problem_id: leet_code_problem.id }
        }.to change(LeetCodeSessionProblem, :count).by(1)
      end

      it 'redirects with success message' do
        post :add_problem, params: { session_id: leet_code_session.id, problem_id: leet_code_problem.id }
        expect(response).to redirect_to(leetcode_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(LeetCodeProblem).to receive(:find).and_raise(StandardError.new('Unexpected error'))
      end

      it 'redirects with an error message' do
        post :add_problem, params: { session_id: leet_code_session.id, problem_id: leet_code_problem.id }
        expect(response).to redirect_to(leetcode_path)
        expect(flash[:alert]).to include('Failed to add problem to session')
      end
    end
  end

  describe '#initialize_google_calendar_service_for (private method)' do
    let(:mock_service) { instance_double('Google::Apis::CalendarV3::CalendarService') }
    let(:mock_credentials) { instance_double('Signet::OAuth2::Client') }
    let(:mock_client_options) { double('client_options') }

    context 'when user has valid tokens' do
      before do
        user.update!(
          google_access_token: 'access_token',
          google_refresh_token: 'refresh_token'
        )
        allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:client_options).and_return(mock_client_options)
        allow(mock_client_options).to receive(:application_name=)
        allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_credentials)
        allow(mock_credentials).to receive(:expired?).and_return(false)
        allow(mock_service).to receive(:authorization=)
      end

      it 'returns a Google Calendar service instance' do
        service = controller.send(:initialize_google_calendar_service_for, user)
        expect(service).to eq(mock_service)
      end
    end

    context 'when user has no access token' do
      before do
        user.update!(google_access_token: nil, google_refresh_token: nil)
      end

      it 'returns nil' do
        service = controller.send(:initialize_google_calendar_service_for, user)
        expect(service).to be_nil
      end
    end

    context 'when token is expired and needs refresh' do
      before do
        user.update!(
          google_access_token: 'old_access_token',
          google_refresh_token: 'refresh_token'
        )
        allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:client_options).and_return(mock_client_options)
        allow(mock_client_options).to receive(:application_name=)
        allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_credentials)
        allow(mock_credentials).to receive(:expired?).and_return(true)
        allow(mock_credentials).to receive(:refresh!)
        allow(mock_credentials).to receive(:access_token).and_return('new_access_token')
        allow(mock_credentials).to receive(:refresh_token).and_return('new_refresh_token')
        allow(mock_service).to receive(:authorization=)
      end

      it 'refreshes the token' do
        expect(mock_credentials).to receive(:refresh!)
        controller.send(:initialize_google_calendar_service_for, user)
      end

      it 'updates user with new tokens' do
        controller.send(:initialize_google_calendar_service_for, user)
        user.reload
        expect(user.google_access_token).to eq('new_access_token')
      end

      it 'returns the service instance' do
        service = controller.send(:initialize_google_calendar_service_for, user)
        expect(service).to eq(mock_service)
      end
    end

    context 'when token refresh fails' do
      before do
        user.update!(
          google_access_token: 'old_access_token',
          google_refresh_token: 'refresh_token'
        )
        allow(Google::Apis::CalendarV3::CalendarService).to receive(:new).and_return(mock_service)
        allow(mock_service).to receive(:client_options).and_return(mock_client_options)
        allow(mock_client_options).to receive(:application_name=)
        allow(Signet::OAuth2::Client).to receive(:new).and_return(mock_credentials)
        allow(mock_credentials).to receive(:expired?).and_return(true)
        allow(mock_credentials).to receive(:refresh!).and_raise(StandardError.new('Refresh failed'))
      end

      it 'logs the error and returns nil' do
        expect(Rails.logger).to receive(:error).with(/Failed to refresh Google token/)
        service = controller.send(:initialize_google_calendar_service_for, user)
        expect(service).to be_nil
      end
    end
  end

  describe '#update_google_calendar_event (private method)' do
    let(:mock_service) { instance_double('Google::Apis::CalendarV3::CalendarService') }
    let(:mock_event) { instance_double('Google::Apis::CalendarV3::Event', description: 'Original description') }

    context 'when service is available and event exists' do
      before do
        allow(controller).to receive(:initialize_google_calendar_service_for).and_return(mock_service)
        allow(mock_service).to receive(:get_event).and_return(mock_event)
        allow(mock_service).to receive(:update_event).and_return(mock_event)
        allow(mock_event).to receive(:description=)
      end

      it 'updates the event description with problem details' do
        expect(mock_event).to receive(:description=).with(include(leet_code_problem.title))
        controller.send(:update_google_calendar_event, leet_code_session, leet_code_problem)
      end

      it 'calls update_event on the service' do
        expect(mock_service).to receive(:update_event).with('primary', 'test_event_id', mock_event)
        controller.send(:update_google_calendar_event, leet_code_session, leet_code_problem)
      end
    end

    context 'when service is not available' do
      before do
        allow(controller).to receive(:initialize_google_calendar_service_for).and_return(nil)
      end

      it 'does not raise an error' do
        expect {
          controller.send(:update_google_calendar_event, leet_code_session, leet_code_problem)
        }.not_to raise_error
      end
    end

    context 'when session has no google_event_id' do
      before do
        leet_code_session.update!(google_event_id: nil)
      end

      it 'does not attempt to update calendar' do
        mock_service = instance_double('Google::Apis::CalendarV3::CalendarService')
        allow(controller).to receive(:initialize_google_calendar_service_for).and_return(mock_service)
        expect(mock_service).not_to receive(:get_event)
        controller.send(:update_google_calendar_event, leet_code_session, leet_code_problem)
      end
    end

    context 'when Google API raises an error' do
      before do
        allow(controller).to receive(:initialize_google_calendar_service_for).and_return(mock_service)
        allow(mock_service).to receive(:get_event).and_raise(Google::Apis::ClientError.new('API Error'))
      end

      it 'logs the error and does not raise' do
        expect(Rails.logger).to receive(:error).with(/Google API client error/)
        expect {
          controller.send(:update_google_calendar_event, leet_code_session, leet_code_problem)
        }.not_to raise_error
      end
    end
  end
end
