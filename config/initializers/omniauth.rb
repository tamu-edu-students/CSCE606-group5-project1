Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV["GOOGLE_CLIENT_ID"],
           ENV["GOOGLE_CLIENT_SECRET"],
           {
             scope: "openid email profile https://www.googleapis.com/auth/calendar.events",
             prompt: "select_account",
             access_type: "offline",
             image_aspect_ratio: "square",
             image_size: 50
           }
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
