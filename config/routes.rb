Rails.application.routes.draw do
  # --- Root Page ---
  # Sets the application"s home page to the login screen.
  root "login#index"

  # --- Authentication / Session Management ---
  get "/login/google", to: redirect("/auth/google_oauth2")
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  delete "/logout", to: "sessions#destroy"
  get "sessions/create", to: "sessions#create", as: "sessions_create"
  get "sessions/failure", to: "sessions#failure", as: "sessions_failure"

  # --- Users / Profile ---
  resources :users, only: [:show, :update]

  # --- Core LeetCode Resources (API-style, no views) ---
  resources :leet_code_problems, except: [:new, :edit]
  resources :leet_code_sessions, except: [:new, :edit]
  resources :leet_code_session_problems, except: [:new, :edit]
  resources :leet_code_entries, only: [:index, :new, :create] 

  # --- Static Pages ---
  get "/dashboard", to: "dashboard#show"
  get "/calendar", to: "calendar#show"
  get "/timer", to: "timer#show"
  post "create_timer", to: "dashboard#create_timer"

  # --- API Routes ---
  namespace :api do
    get "current_user", to: "users#profile"
    get "calendar_events", to: "calendar#events"
  end

  # --- Health Check ---
  get "up" => "rails/health#show", as: :rails_health_check
end
