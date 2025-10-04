Rails.application.routes.draw do
  # Root page
  root "login#index"

  # -------------------------------
  # Authentication / Sessions
  # -------------------------------
  get "/login/google",          to: redirect("/auth/google_oauth2")
  get "/auth/:provider/callback", to: "sessions#create"
  get "sessions/create", to: "sessions#create", as: "sessions_create"
  get "/auth/failure",          to: "sessions#failure", as: "sessions_failure"
  delete "/logout",             to: "sessions#destroy"
  get "/debug/session",         to: "sessions#debug"

  # -------------------------------
  # Dashboard, Calendar, Timer
  # -------------------------------
  get "/dashboard",             to: "dashboard#show"
  get "/calendar",              to: "calendar#show"
  post "/calendar/sync",        to: "calendar#sync", as: "sync_calendar"
  get "/calendar/add",          to: "calendar#new", as: "add_calendar_event"
  get "/calendar/:id/edit",     to: "calendar#edit", as: "edit_calendar_event"

  get "/timer",                 to: "timer#show"
  post "/create_timer",         to: "dashboard#create_timer"

  # -------------------------------
  # Profile / User
  # -------------------------------
  get "/profile",               to: "users#profile", as: :profile
  resources :users, only: [ :show, :update ]

  # -------------------------------
  # LeetCode Features
  # -------------------------------
  get "/leetcode",              to: "leet_code_problems#show"

  resources :leet_code_problems, except: [ :new, :edit ]
  resources :leet_code_sessions, except: [ :new, :edit ] do
    post :add_problem, on: :collection
  end
  resources :leet_code_session_problems, except: [ :new, :edit ]

  resource  :statistics, only: [ :show ], controller: "statistics"

  # -------------------------------
  # API Namespace
  # -------------------------------
  namespace :api do
    get "current_user", to: "users#profile"

    # Calendar Events CRUD
    get    "calendar_events",     to: "calendar#events",   as: "calendar_events"
    post   "calendar_events",     to: "calendar#create"
    patch  "calendar_events/:id", to: "calendar#update",   as: "calendar_event"
    delete "calendar_events/:id", to: "calendar#destroy"
  end

  # -------------------------------
  # Health Check & Favicon
  # -------------------------------
  get "up", to: "rails/health#show", as: :rails_health_check
  get "favicon.ico", to: proc { [ 204, {}, [] ] }
end
