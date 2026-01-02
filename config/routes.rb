Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Devise routes with custom controllers (for admins only)
  # Registration disabled - users should register as attendees or counsellors instead
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }, skip: [ :registrations ]

  # Only allow edit/update/destroy for existing users, not new registrations
  devise_scope :user do
    get "users/edit", to: "users/registrations#edit", as: :edit_user_registration
    patch "users", to: "users/registrations#update", as: :user_registration
    put "users", to: "users/registrations#update"
    delete "users", to: "users/registrations#destroy"
  end

  # OTP verification routes
  namespace :users do
    get "otp/verify", to: "otp_sessions#new", as: "otp_verify"
    post "otp/verify", to: "otp_sessions#create"
    post "otp/resend", to: "otp_sessions#resend", as: "otp_resend"
  end

  # Two-factor authentication settings
  get "users/two_factor_settings", to: "users/two_factor_settings#index", as: "users_two_factor_settings"
  patch "users/two_factor_settings", to: "users/two_factor_settings#update"

  # Attendee registration (no login, data collection only)
  resources :attendee_registrations, only: [ :create ]
  get "attendees/register", to: "attendee_registrations#new", as: "new_attendee"

  # Counsellor registration (no login, data collection only)
  resources :counsellors, only: [ :create ]
  get "counsellors/register", to: "counsellors#new", as: "new_counsellor"

  # Admin routes (password protected)
  get "admin/login", to: "admin#login", as: "admin_login"
  post "admin/authenticate", to: "admin#authenticate", as: "admin_authenticate"
  delete "admin/logout", to: "admin#logout", as: "admin_logout"
  get "admin", to: "admin#index", as: "admin"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Info pages
  get "attendee_info", to: "home#attendee_info", as: "attendee_info"
  get "counsellor_info", to: "home#counsellor_info", as: "counsellor_info"

  # Defines the root path route ("/")
  root "home#index"
end
