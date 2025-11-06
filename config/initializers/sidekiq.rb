# config/initializers/sidekiq.rb

if Rails.env.test?
  # En entorno de test no queremos conectarnos a Redis real
  Sidekiq.configure_server do |config|
    config.redis = { url: "redis://localhost:6378/0", size: 1 }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://localhost:6378/0", size: 1 }
  end

  # Evitar que se creen jobs programados durante las pruebas
  puts "[Sidekiq] Skipping cron jobs in test environment"
else
  redis_url =
    if Rails.env.development?
      "redis://localhost:6378/0" # Redis local para desarrollo
    else
      ENV.fetch("REDIS_URL")      # Redis de producción
    end

  Sidekiq.configure_server do |config|
    config.redis = { url: redis_url }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: redis_url }
  end

  # Configurar jobs recurrentes solo en desarrollo/producción
  Sidekiq::Cron::Job.create(
    name: "Cleanup Expired Tokens",
    cron: "0 2 * * *", # Ejecutar diariamente a las 2 AM
    class: "CleanupExpiredTokensJob"
  )

  Sidekiq::Cron::Job.create(
    name: "Cleanup Past Class Sessions",
    cron: "0 * * * *", # Ejecutar cada hora
    class: "CleanupPastClassSessionsJob"
  )
end
