class CleanupExpiredTokensJob
  include Sidekiq::Job

  def perform
    # Limpiar tokens blacklisted expirados
    blacklisted_count = BlacklistedToken.cleanup_expired!

    # Limpiar refresh tokens expirados
    refresh_count = RefreshTokenUser.where("expires_at <= ?", Time.current).delete_all

    Rails.logger.info "Cleaned up #{blacklisted_count} blacklisted tokens and #{refresh_count} refresh tokens"
  end
end
