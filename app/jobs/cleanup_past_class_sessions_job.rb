class CleanupPastClassSessionsJob
  include Sidekiq::Job

  def perform
    # Eliminar clases que ya terminaron (end_time < ahora)
    # Usamos destroy_all para respetar las asociaciones (class_spaces, reservations)
    past_sessions = ClassSession.where("end_time < ?", Time.current)
    deleted_count = 0

    past_sessions.find_each do |session|
      session.destroy
      deleted_count += 1
    rescue StandardError => e
      Rails.logger.error "Error deleting class session #{session.id}: #{e.message}"
    end

    Rails.logger.info "Cleaned up #{deleted_count} past class sessions"
  end
end
