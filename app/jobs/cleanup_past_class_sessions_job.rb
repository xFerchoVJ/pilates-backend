class CleanupPastClassSessionsJob
  include Sidekiq::Job

  def perform
    deleted_count = 0
    one_hour_from_now = 1.hour.from_now

    # Caso 1: Eliminar clases sin reservaciones que inician en 1 hora o menos
    sessions_without_reservations = ClassSession
      .left_joins(:reservations)
      .where(reservations: { id: nil })
      .where("start_time <= ?", one_hour_from_now)
      .where("start_time > ?", Time.current)

    Rails.logger.info "Found #{sessions_without_reservations.count} sessions without reservations starting within 1 hour"

    sessions_without_reservations.find_each do |session|
      session.destroy
      deleted_count += 1
      Rails.logger.info "Deleted session #{session.id} (#{session.name}) - no reservations, starts at #{session.start_time}"
    rescue StandardError => e
      Rails.logger.error "Error deleting session #{session.id}: #{e.message}"
    end

    # Caso 2: Eliminar clases que ya iniciaron (start_time < ahora)
    started_sessions = ClassSession.where("start_time < ?", Time.current)

    Rails.logger.info "Found #{started_sessions.count} sessions that have already started"

    started_sessions.find_each do |session|
      session.destroy
      deleted_count += 1
      Rails.logger.info "Deleted session #{session.id} (#{session.name}) - already started at #{session.start_time}"
    rescue StandardError => e
      Rails.logger.error "Error deleting session #{session.id}: #{e.message}"
    end

    Rails.logger.info "Cleaned up #{deleted_count} class sessions total"
  end
end
