require "google-id-token"

class GoogleIdTokenService
  def self.verify(id_token)
    validator = GoogleIDToken::Validator.new
    aud = Rails.application.credentials.dig(:google, :client_id) || ENV["GOOGLE_CLIENT_ID"]
    payload = validator.check(id_token, aud, aud) # audience y client_id iguales (apps nativas usan el mismo client_id)
    payload&.with_indifferent_access
  rescue GoogleIDToken::ValidationError
    nil
  end
end
