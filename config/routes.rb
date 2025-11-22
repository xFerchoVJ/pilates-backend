require "sidekiq/web"
require "rack/session" # 👈 agrega esta línea


# Habilita sesiones solo para el panel de Sidekiq
Sidekiq::Web.use Rack::Session::Cookie, secret: ENV.fetch("SIDEKIQ_SESSION_SECRET") { SecureRandom.hex(32) }

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Panel Sidekiq (requiere sesión para CSRF)
  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "signup",   to: "auth#signup"
      post "login",    to: "auth#login"
      post "google",   to: "auth#google"
      post "refresh",  to: "auth#refresh"
      post "logout",   to: "auth#logout"
      get "me",        to: "auth#me"
      post "logout_all", to: "auth#logout_all"
      post "cleanup_tokens", to: "auth#cleanup_tokens"
      post "stripe_webhooks", to: "stripe_webhooks#receive"

      resources :class_sessions do
        collection { post :create_recurring }
      end
      resources :class_packages do
        collection { post :purchase_with_payment }
      end
      resources :class_waitlist_notifications, only: [ :create, :destroy ]
      resources :class_credits, only: [ :index, :show ]
      resources :coupons do
        collection { post :validate }
      end
      resources :devices
      resources :lounges
      resources :lounges_designs
      resources :injuries do
        collection { get :injuries_by_user }
      end
      resources :reservations do
        collection { post :create_with_payment }
      end
      resources :transactions, only: [ :index, :show ]
      resources :users do
        collection do
          post "validate_password_reset_token"
          post "send_password_reset"
          patch "reset_password"
        end
      end
      resources :user_class_packages, only: [ :index, :show ]
    end
  end
end
