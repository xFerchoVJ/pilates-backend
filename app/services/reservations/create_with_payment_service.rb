# app/services/reservations/create_with_payment_service.rb
class Reservations::CreateWithPaymentService
  def initialize(class_session_id:, user:, class_space_id:)
    @class_session_id = class_session_id
    @user = user
    @class_space_id = class_space_id
  end

  def call
    return validate_required_params unless valid_required_params?

    class_session = find_class_session
    validation_error = validate_class_session(class_session)
    return validation_error if validation_error

    class_space = find_class_space(class_session)
    validation_error = validate_class_space(class_space)
    return validation_error if validation_error

    active_package = @user.user_class_packages.active.first

    if active_package&.remaining_classes.to_i > 0
      begin
        reservation = Reservation.create!(
          user: @user,
          class_session: class_session,
          class_space: class_space
        )
        class_space.update!(status: :reserved)
        active_package.consume_class!
        Transaction.create!(
          user: @user,
          amount: 0,
          currency: "mxn",
          transaction_type: "class_redeemed",
          reference_type: "Reservation",
          reference: reservation,
          status: :succeeded,
          payment_intent_id: "#{@user.email}-#{reservation.id}-#{Time.current.to_i}"
        )
        return success(client_secret: nil)
      rescue => e
        Rails.logger.error "Error creating reservation: #{e.message}"
        return failure("Error al crear la reserva")
      end
    end

    service = Payments::PaymentIntentService.new(
      user: @user,
      amount: class_session.price,
      currency: "mxn",
      transaction_type: "class_payment",
      reference: class_session,
      reference_type: "ClassSession",
      metadata: {
        user_id: @user.id,
        class_session_id: class_session.id,
        class_space_id: @class_space_id
      }
    )
    result = service.call
    if result[:success]
      success(client_secret: result[:client_secret])
    else
      failure(result[:message])
    end
  end

  private

  def validate_required_params
    return log_and_fail("El id de la clase es requerido") if @class_session_id.blank?
    return log_and_fail("El usuario es requerido") if @user.blank?
    return log_and_fail("El espacio de clase es requerido") if @class_space_id.blank?

    nil
  end

  def valid_required_params?
    @class_session_id.present? && @user.present? && @class_space_id.present?
  end

  def find_class_session
    ClassSession.find_by(id: @class_session_id)
  end

  def validate_class_session(class_session)
    return log_and_fail("La clase no fue encontrada") if class_session.blank?
    return log_and_fail("La clase no tiene espacios") if class_session.class_spaces.empty?
    return log_and_fail("La clase no tiene espacios disponibles") if class_session.full?

    nil
  end

  def find_class_space(class_session)
    class_session.class_spaces.find { |space| space.id == @class_space_id }
  end

  def validate_class_space(class_space)
    return log_and_fail("El espacio de clase no fue encontrado") if class_space.blank?
    return log_and_fail("El espacio de clase no está disponible") unless class_space.available?

    nil
  end

  def log_and_fail(message)
    Rails.logger.error(message)
    failure(message)
  end

  def success(data)
    { success: true }.merge(data)
  end

  def failure(message)
    { success: false, message: message }
  end
end
