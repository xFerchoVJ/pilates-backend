class Reservations::ConfirmPaymentService
  def initialize(payment_intent_id, user, class_space_id)
    @payment_intent_id = payment_intent_id
    @user = user
    @class_space_id = class_space_id
  end

  def call
    if @payment_intent_id.nil? || @user.nil?
      { success: false, message: "El id de la intención de pago y el usuario son requeridos" }
    end

    transaction = Transaction.find_by(payment_intent_id: @payment_intent_id)

    begin
      if payment_intent.status == "succeeded"
        transaction.update!(status: :succeeded)
        reservation = Reservation.create!(
          user: @user,
          class_session: payment_intent.metadata["class_session_id"],
          class_space_id: @class_space_id
        )

        transaction.update!(reference: reservation)
        { success: true, message: "Pago confirmado correctamente", reservation: reservation }
      else
        transaction.update!(status: :failed)
        { success: false, message: "Pago no confirmado" }
      end
    rescue => e
      Rails.logger.error "Error confirming payment: #{e.message}"
      { success: false, message: "Error interno." }
    end
  end

  private

  def payment_intent
    Stripe::PaymentIntent.retrieve(@payment_intent_id)
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error "Error retrieving payment intent: #{e.message}"
    { success: false, message: "Error al obtener la intención de pago" }
  end
end
