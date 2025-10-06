# Adds Google OAuth token storage for Calendar API integration
class AddGoogleTokensToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_access_token, :string      # OAuth access token for API calls
    add_column :users, :google_refresh_token, :string     # Refresh token for token renewal
    add_column :users, :google_token_expires_at, :datetime # Token expiration timestamp
  end
end
