# config/initializers/sidekiq.rb

redis_url =
  if Rails.env.development?
    'redis://localhost:6378/0' # Redis local para desarrollo
  else
    ENV.fetch('REDIS_URL')      # Redis de producción
  end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# Configurar jobs recurrentes
Sidekiq::Cron::Job.create(
  name: 'Cleanup Expired Tokens',
  cron: '0 2 * * *', # Ejecutar diariamente a las 2 AM
  class: 'CleanupExpiredTokensJob'
)
