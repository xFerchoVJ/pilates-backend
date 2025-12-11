class CleanupPastClassSessionsJob
  include Sidekiq::Job

  def perform
    deleted_count = 0
    soft_deleted_count = 0
    one_hour_from_now = 1.hour.from_now

    # Caso 1: Cancelar (Soft Delete) clases sin reservaciones que inician en 1 hora o menos
    sessions_without_reservations = ClassSession
      .left_joins(:reservations)
      .active
      .where(reservations: { id: nil })
      .where("start_time <= ?", one_hour_from_now)
      .where("start_time > ?", Time.current)

    Rails.logger.info "Found #{sessions_without_reservations.count} sessions without reservations starting within 1 hour"

    sessions_without_reservations.find_each do |session|
      session.soft_delete!
      soft_deleted_count += 1
      Rails.logger.info "Soft deleted session #{session.id} (#{session.name}) - no reservations, starts at #{session.start_time}"
    rescue StandardError => e
      Rails.logger.error "Error soft deleting session #{session.id}: #{e.message}"
    end

    # Caso 2: Limpieza definitiva (Hard Delete) - Retención de 8 días

    # a) Clases eliminadas manualmente hace más de 8 días
    deleted_old_sessions = ClassSession.deleted.where("deleted_at < ?", 8.days.ago)

    deleted_old_sessions.find_each do |session|
      session.destroy
      deleted_count += 1
      Rails.logger.info "Hard deleted session #{session.id} (#{session.name}) - deleted_at #{session.deleted_at} > 8 days ago"
    rescue StandardError => e
      Rails.logger.error "Error hard deleting session #{session.id}: #{e.message}"
    end

    # b) Clases finalizadas hace más de 8 días (y que no han sido eliminadas manualmente, o si lo fueron, caen en el caso anterior si deleted_at es viejo)
    # Para evitar doble borrado, buscamos active (o podríamos borrar todas, destroy es idempotente si ya no existe, pero find_each fallaría si se borra en medio)
    # Mejor borrar las active que terminaron hace tiempo.
    finished_old_sessions = ClassSession.active.where("end_time < ?", 8.days.ago)

    finished_old_sessions.find_each do |session|
      session.destroy
      deleted_count += 1
      Rails.logger.info "Hard deleted session #{session.id} (#{session.name}) - end_time #{session.end_time} > 8 days ago"
    rescue StandardError => e
      Rails.logger.error "Error hard deleting finish session #{session.id}: #{e.message}"
    end

    Rails.logger.info "Cleanup Job Done. Soft deleted: #{soft_deleted_count}, Hard deleted: #{deleted_count}"
  end
end
