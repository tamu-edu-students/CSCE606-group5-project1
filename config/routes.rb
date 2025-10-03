# config/routes.rb
Rails.application.routes.draw do
  # --- Root Page ---
  # Sets the application"s home page to the login screen.
  root "login#index"
  # Add debug session route
  get "/debug/session", to: "sessions#debug"
  # --- Authentication / Session Management ---
  get "/login/google", to: redirect("/auth/google_oauth2")
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy"
  get "sessions/create", to: "sessions#create", as: "sessions_create"
  get "sessions/failure", to: "sessions#failure", as: "sessions_failure"

  # --- User-Facing Pages & Resources ---
  resources :users
  get "/profile", to: "users#profile", as: :profile
  resources :leet_code_entries, only: [ :index, :new, :create ]

  # --- Static Pages ---
  get "/dashboard", to: "dashboard#show"
  get "/calendar", to: "calendar#show"
  get "/calendar/:id/edit", to: "calendar#edit", as: "edit_calendar_event"
  get "/timer", to: "timer#show"
  post "create_timer", to: "dashboard#create_timer"

  # --- API Routes ---
  namespace :api do
    # resources :calendar_events, only: [:index, :create, :update, :destroy]
    get "current_user", to: "users#profile"
    # Calendar CRUD
    get "calendar_events", to: "calendar#events", as: "calendar_events"
    post   "calendar_events",         to: "calendar#create"
    patch  "calendar_events/:id",     to: "calendar#update", as: "calendar_event"
    delete "calendar_events/:id",     to: "calendar#destroy"
  end

  # --- Health Check ---
  get "up" => "rails/health#show", as: :rails_health_check
end
