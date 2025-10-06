module AuthenticationHelpers
  def login_as(netid)
    user = User.find_by!(netid: netid)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "12345",
      info: {
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        name: "#{user.first_name} #{user.last_name}"
      },
      credentials: {
        token: "mock_google_token",
        refresh_token: "mock_google_refresh_token",
        expires_at: Time.now.to_i + 3600
      }
    })

    visit "/auth/google_oauth2/callback"
  end
end

World(AuthenticationHelpers)