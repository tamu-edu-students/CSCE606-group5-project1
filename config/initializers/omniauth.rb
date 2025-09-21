Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV['GOOGLE_CLIENT_ID'],
           ENV['GOOGLE_CLIENT_SECRET'],
           {
             scope: 'userinfo.email,calendar,openid,profile',
             prompt: 'select_account',
             image_aspect_ratio: 'square',
             image_size: 200,
             name: 'google_oauth2',
             access_type: 'offline'
           }
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
