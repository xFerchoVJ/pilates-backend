# app/services/reservations/create_with_payment_service.rb
class Reservations::CreateWithPaymentService
  def initialize(class_session_id:, user:, class_space_id:)
    @class_session_id = class_session_id
    @user = user
    @class_space_id = class_space_id
  end

  def call
    return failure("El id de la clase es requerido") if @class_session_id.blank?
    return failure("El usuario es requerido") if @user.blank?
    return failure("El espacio de clase es requerido") if @class_space_id.blank?

    class_session = ClassSession.find_by(id: @class_session_id)
    return failure("La clase no fue encontrada") unless class_session
    return failure("La clase no tiene espacios") if class_session.class_spaces.empty?
    return failure("La clase no tiene espacios disponibles") if class_session.full?

    class_space = class_session.class_spaces.find { |space| space.id == @class_space_id }
    return failure("El espacio de clase no fue encontrada") unless class_space

    active_package = @user.user_class_packages.active.first

    if active_package&.remaining_classes.to_i > 0
      begin
        reservation = Reservation.create!(
          user: @user,
          class_session: class_session,
          class_space: class_space
        )
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

  def success(data)
    { success: true }.merge(data)
  end

  def failure(message)
    { success: false, message: message }
  end
end
