OmniAuth.config.test_mode = true

OmniAuth.config.request_validation_phase = nil

After do
  OmniAuth.config.mock_auth[:google_oauth2] = nil
end
