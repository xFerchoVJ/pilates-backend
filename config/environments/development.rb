require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Recarga el código de la app en cada request
  config.enable_reloading = true

  # No eager load
  config.eager_load = false

  # Mostrar errores completos
  config.consider_all_requests_local = true

  # Habilitar server timing
  config.server_timing = true

  # Caching
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.cache_store = :redis_cache_store, { url: "redis://localhost:6378/0" }
    config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Active Storage
  config.active_storage.service = :cloudinary

  # Mailer
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
  address:              "smtp-relay.brevo.com",
  port:                 587,
  user_name:            ENV["BREVO_USERNAME"], # suele ser tu email
  password:             ENV["BREVO_SMTP_KEY"],
  authentication:       'plain',
  enable_starttls_auto: true
}

  # Deprecation
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # DB
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true

  # Active Job logs
  config.active_job.verbose_enqueue_logs = true

  # Sidekiq con Redis local
  config.active_job.queue_adapter = :sidekiq
  Sidekiq.configure_server do |sidekiq_config|
    sidekiq_config.redis = { url: "redis://localhost:6378/0" }
  end
  Sidekiq.configure_client do |sidekiq_config|
    sidekiq_config.redis = { url: "redis://localhost:6378/0" }
  end

  # Views
  config.action_view.annotate_rendered_view_with_filenames = true

  # Callbacks
  config.action_controller.raise_on_missing_callback_actions = true
end
