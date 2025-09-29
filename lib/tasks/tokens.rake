namespace :tokens do
  desc "Clean up expired tokens"
  task cleanup: :environment do
    puts "Cleaning up expired tokens..."

    blacklisted_count = BlacklistedToken.cleanup_expired!
    refresh_count = RefreshTokenUser.where("expires_at <= ?", Time.current).delete_all

    puts "Cleaned up #{blacklisted_count} blacklisted tokens"
    puts "Cleaned up #{refresh_count} refresh tokens"
    puts "Cleanup completed!"
  end

  desc "Schedule cleanup job with Sidekiq"
  task schedule_cleanup: :environment do
    CleanupExpiredTokensJob.perform_async
    puts "Cleanup job scheduled with Sidekiq"
  end
end
