Rails.application.routes.draw do
  # Root page
  root "login#index"

  # --- Dashboard ---
  get "/dashboard", to: "dashboard#index"

  # --- OAuth / Sessions ---
  get    "/auth/:provider/callback", to: "sessions#create"
  get    "/auth/failure",            to: "sessions#failure"
  get    "/login/google",            to: redirect("/auth/google_oauth2")
  delete "/logout",                  to: "sessions#destroy"

  # --- Users / Profile ---
  resources :users, only: [:show, :update]

  # --- Core LeetCode Resources (API-style, no views) ---
  resources :leet_code_problems, except: [:new, :edit]
  resources :leet_code_sessions, except: [:new, :edit]
  resources :leet_code_session_problems, except: [:new, :edit]
  resources :leet_code_entries, only: [:index, :new, :create] 

  # --- API namespace ---
  namespace :api do
    get "current_user",    to: "users#profile"
    get "calendar_events", to: "calendar#events"
  end

  # --- Misc / System ---
  get "up" => "rails/health#show", as: :rails_health_check

  # --- Legacy or unused ---
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
