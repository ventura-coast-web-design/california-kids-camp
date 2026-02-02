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
  resources :attendee_registrations, only: [ :create, :show ] do
    member do
      get :payment
      post :create_payment_intent
      post :payment_success
    end
  end
  get "attendees/register", to: "attendee_registrations#new", as: "new_attendee"

  # Counsellor registration (no login, data collection only)
  # Specific route must come before resources to avoid route conflict
  get "counsellors/register", to: "counsellors#new", as: "new_counsellor"
  resources :counsellors, only: [ :create, :show ]

  # Admin routes (password protected)
  get "admin/login", to: "admin#login", as: "admin_login"
  post "admin/authenticate", to: "admin#authenticate", as: "admin_authenticate"
  delete "admin/logout", to: "admin#logout", as: "admin_logout"
  get "admin", to: "admin#index", as: "admin"
  get "admin/export_attendees", to: "admin#export_attendees", as: "admin_export_attendees"
  get "admin/export_counsellors", to: "admin#export_counsellors", as: "admin_export_counsellors"
  get "admin/attendees/:id", to: "admin#show_attendee", as: "admin_attendee"
  get "admin/counsellors/:id", to: "admin#show_counsellor", as: "admin_counsellor"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Info pages
  get "attendee_info", to: "home#attendee_info", as: "attendee_info"
  get "counsellor_info", to: "home#counsellor_info", as: "counsellor_info"
  get "rules", to: "home#rules", as: "rules"
  get "workbooks", to: "home#workbooks", as: "workbooks"

  # Balance payment routes
  get "balance_payment/lookup", to: "balance_payments#lookup", as: "balance_payment_lookup"
  post "balance_payment/lookup", to: "balance_payments#find_registration"
  get "balance_payment/:id", to: "balance_payments#show", as: "balance_payment"
  get "balance_payment/:id/confirmation", to: "balance_payments#confirmation", as: "balance_payment_confirmation"
  post "balance_payment/:id/create_payment_intent", to: "balance_payments#create_payment_intent", as: "balance_payment_create_intent"
  post "balance_payment/:id/payment_success", to: "balance_payments#payment_success", as: "balance_payment_success"

  # Defines the root path route ("/")
  root "home#index"
end
