require 'rails_helper'

RSpec.describe GoogleCalendarSyncJob, type: :job do
  # Create a test user and sample session data
  let(:user) { create(:user) }
  let(:session_data) do
    {
      "google_token" => "test_token",
      "google_refresh_token" => "test_refresh_token",
      "google_token_expires_at" => (Time.current + 1.hour).to_i
    }
  end

  # This is the main test that verifies the job calls the correct service
  it 'calls the GoogleCalendarSync service with the correct user and session data' do
    # We expect the GoogleCalendarSync service to receive the `sync_for_user` call.
    # We allow it to return a success message for this test.
    expect(GoogleCalendarSync).to receive(:sync_for_user)
      .with(user, an_instance_of(Hash))
      .and_return({ success: true })

    # perform_now runs the job immediately in the test
    described_class.perform_now(user.id, session_data)
  end

  context 'when the sync is successful' do
    before do
      # For this context, we stub the service to always return a success hash
      allow(GoogleCalendarSync).to receive(:sync_for_user).and_return({ success: true, synced: 10 })
    end

    it 'logs an info message' do
        allow(Rails.logger).to receive(:info)
        described_class.perform_now(user.id, session_data)
        expect(Rails.logger).to have_received(:info).with(/Background sync completed/)
    end
  end

  context 'when the sync fails' do
    before do
      # For this context, we stub the service to always return a failure hash
      allow(GoogleCalendarSync).to receive(:sync_for_user).and_return({ success: false, error: 'API Error' })
    end

    it 'logs an error message' do
      # We expect Rails.logger to receive an :error message containing the failure text
      expect(Rails.logger).to receive(:error).with(/Background sync failed/)
      described_class.perform_now(user.id, session_data)
    end
  end

  it 'raises an error if the user_id is not found' do
    invalid_user_id = -1
    # This test verifies the job fails as expected if the user has been deleted
    expect {
      described_class.perform_now(invalid_user_id, session_data)
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
