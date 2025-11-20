class Reservations::CreateWithPaymentService
  def initialize(class_session_id:, user:, class_space_id:)
    @class_session_id = class_session_id
    @user = user
    @class_space_id = class_space_id
  end

  def call
    return validate_required_params unless valid_required_params?

    @class_session = find_class_session
    return failure("La clase no fue encontrada") unless @class_session
    return failure("La clase no tiene espacios") if @class_session.class_spaces.empty?
    return failure("La clase no tiene espacios disponibles") if @class_session.full?

    @class_space = find_class_space(@class_session)
    return failure("El espacio de clase no fue encontrado") unless @class_space
    return failure("El espacio de clase no está disponible") unless @class_space.available?

    return reserve_with_credit if available_credit?

    return reserve_with_package if available_package?

    create_payment_intent
  end

  private

  def validate_required_params
    return failure("El id de la clase es requerido") if @class_session_id.blank?
    return failure("El usuario es requerido") if @user.blank?
    failure("El espacio de clase es requerido") if @class_space_id.blank?
  end

  def valid_required_params?
    @class_session_id.present? && @user.present? && @class_space_id.present?
  end

  def find_class_session
    ClassSession.find_by(id: @class_session_id)
  end

  def find_class_space(class_session)
    class_session.class_spaces.find { |space| space.id == @class_space_id }
  end

  def available_credit?
    @credit ||= @user.class_credits.where(status: "unused").first
  end

  def reserve_with_credit
    result = nil
    ActiveRecord::Base.transaction do
      reservation = create_reservation!
      unless reservation
        result = failure("Error al crear reserva con crédito")
        raise ActiveRecord::Rollback
      end

      @credit.update!(status: "used", used_at: Time.current)
      create_transaction!(
        type: Transaction.transaction_types[:class_credit_used],
        reservation: reservation
      )
      result = success(client_secret: nil)
    end
    result || failure("Error al crear reserva con crédito")
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error de validación: #{e.message}"
    failure("Error de validación: #{e.record.errors.full_messages.join(', ')}")
  rescue => e
    Rails.logger.error "Error al crear reserva con crédito: #{e.message}"
    failure("Error al crear reserva con crédito")
  end

  def available_package?
    @package ||= @user.user_class_packages.active
                .joins(:class_package)
                .where("user_class_packages.expires_at IS NULL OR user_class_packages.expires_at >= ?", Time.current)
                .order("class_packages.unlimited DESC")
                .first
    return false unless @package

    if @package.class_package.unlimited?
      !exceeded_unlimited_daily_limit?
    else
      @package.remaining_classes > 0
    end
  end

  def exceeded_unlimited_daily_limit?
    return false unless @package&.class_package&.unlimited?

    daily_limit = @package.class_package.daily_limit
    return false unless daily_limit

    today_reservations = @user.reservations
                              .where(status: true)
                              .where("DATE(created_at) = ?", Date.current)
                              .count

    today_reservations >= daily_limit
  end

  def reserve_with_package
    result = nil
    ActiveRecord::Base.transaction do
      reservation = create_reservation!
      unless reservation
        result = failure("Error al crear reserva con paquete")
        raise ActiveRecord::Rollback
      end

      @package.consume_class! unless @package.class_package.unlimited?
      create_transaction!(
        type: Transaction.transaction_types[:class_redeemed],
        reservation: reservation
      )
      result = success(client_secret: nil)
    end
    result || failure("Error al crear reserva con paquete")
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error de validación: #{e.message}"
    failure("Error de validación: #{e.record.errors.full_messages.join(', ')}")
  rescue => e
    Rails.logger.error "Error al crear reserva con paquete: #{e.message}"
    failure("Error al crear reserva con paquete")
  end

  def create_payment_intent
    service = Payments::PaymentIntentService.new(
      user: @user,
      amount: @class_session.price,
      currency: "mxn",
      transaction_type: Transaction.transaction_types[:class_payment],
      reference: @class_session,
      reference_type: "ClassSession",
      metadata: {
        user_id: @user.id,
        class_session_id: @class_session.id,
        class_space_id: @class_space_id
      }
    )

    result = service.call
    result[:success] ? success(client_secret: result[:client_secret]) : failure(result[:message])
  rescue => e
    Rails.logger.error "Error al crear la reserva con pago: #{e.message}"
    failure("Error interno.")
  end


  def create_reservation!
    @class_space.with_lock do
      return nil unless @class_space.available?

      Reservation.create!(
        user: @user,
        class_session: @class_session,
        class_space: @class_space
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error de validación al crear reserva: #{e.message}"
    raise
  rescue => e
    Rails.logger.error "Error al crear reserva: #{e.message}"
    raise
  end

  def create_transaction!(type:, reservation:)
    Transaction.create!(
      user: @user,
      amount: 0,
      currency: "mxn",
      transaction_type: type,
      reference_type: "Reservation",
      reference: reservation,
      status: :succeeded,
      payment_intent_id: "#{@user.email}-#{reservation.id}-#{Time.current.to_i}"
    )
  end

  def success(data)
    { success: true }.merge(data)
  end

  def failure(message)
    { success: false, message: message }
  end
end
