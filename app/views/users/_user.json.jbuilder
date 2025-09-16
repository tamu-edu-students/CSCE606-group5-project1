json.extract! user, :id, :netid, :email, :first_name, :last_name, :role, :last_login_at, :created_at, :updated_at
json.url user_url(user, format: :json)
