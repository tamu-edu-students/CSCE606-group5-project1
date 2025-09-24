Rails.application.config.session_store :cookie_store,
  key: '_csce606_group5_project1_session',
  secure: Rails.env.production?,  # ensures cookies are marked secure in production
  same_site: :none                # allows cookies to be sent on cross-site redirects
