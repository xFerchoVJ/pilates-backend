Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do
    namespace :v1 do
      post "signup",   to: "auth#signup"
      post "login",    to: "auth#login"
      post "google",   to: "auth#google"   # recibe { id_token }
      post "refresh",  to: "auth#refresh"  # recibe { refresh_token }
      post "logout",        to: "auth#logout"        # opcional { refresh_token }
      post "logout_all",    to: "auth#logout_all"    # logout de todos los dispositivos
      post "cleanup_tokens", to: "auth#cleanup_tokens" # limpiar tokens expirados (solo admin)

      resources :users do
        collection do
          post "send_password_reset"
          patch "reset_password"
        end
      end
    end
  end
end
