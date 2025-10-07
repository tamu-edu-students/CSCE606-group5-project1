# Configures Google OAuth2 authentication for user login and Google Calendar API access
# Requests permissions for user profile and calendar events management
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV["GOOGLE_CLIENT_ID"],
           ENV["GOOGLE_CLIENT_SECRET"],
           {
             scope: "openid email profile https://www.googleapis.com/auth/calendar.events",  # Required permissions
             prompt: "consent",        # Always show consent screen for refresh tokens
             access_type: "offline",   # Get refresh token for long-term API access
             image_aspect_ratio: "square",
             image_size: 50
           }
end

# Allow both GET and POST requests for OAuth callbacks
OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
