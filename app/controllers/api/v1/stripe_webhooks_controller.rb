class Api::V1::StripeWebhooksController < ApplicationController
  skip_before_action :set_current_user

  def receive
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    event = construct_stripe_event(payload, sig_header)
    return render(json: event, status: :bad_request) if event.is_a?(Hash) && event[:error]

    case event.type
    when "payment_intent.succeeded"
      Rails.logger.info "Payment intent succeeded: #{event.data.object.inspect}"
      handle_payment_intent_succeeded(event.data.object)
    when "payment_intent.payment_failed"
      Rails.logger.info "Payment intent failed: #{event.data.object.inspect}"
      handle_payment_intent_failed(event.data.object)
    when "charge.succeeded"
      # Fallback: obtener el PaymentIntent desde el Charge
      charge = event.data.object
      payment_intent_id = charge.payment_intent
      if payment_intent_id
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
        handle_payment_intent_succeeded(payment_intent)
      end
    when "charge.failed"
      # Fallback: obtener el PaymentIntent desde el Charge
      charge = event.data.object
      payment_intent_id = charge.payment_intent
      if payment_intent_id
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)
        handle_payment_intent_failed(payment_intent)
      end
    end

    render json: { status: "ok" }
  end

  private

  def construct_stripe_event(payload, sig_header)
    Stripe::Webhook.construct_event(payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"])
  rescue JSON::ParserError => e
    { error: "Invalid payload: #{e.message}" }
  rescue Stripe::SignatureVerificationError => e
    { error: "Invalid signature: #{e.message}" }
  end

  def handle_payment_intent_succeeded(payment_intent)
    Rails.logger.info "Handling payment intent succeeded: #{payment_intent.inspect}"
    transaction_id = payment_intent.metadata["transaction_id"]
    transaction = if transaction_id
      Transaction.find_by(id: transaction_id)
    else
      # Fallback: buscar por payment_intent_id si no hay metadata
      Transaction.find_by(payment_intent_id: payment_intent.id)
    end
    return unless transaction
    return if transaction.succeeded?

    transaction.update!(
      status: :succeeded,
    )

    case transaction.transaction_type
    when "class_payment"
      create_reservation_from_payment(payment_intent, transaction)
    when "membership_payment"
      activate_membership(transaction)
    when "package_purchase"
      assign_package_to_user(transaction)
    end
  end

  def handle_payment_intent_failed(payment_intent)
    Rails.logger.info "Handling payment intent failed: #{payment_intent.inspect}"
    transaction_id = payment_intent.metadata["transaction_id"]
    transaction = if transaction_id
      Transaction.find_by(id: transaction_id)
    else
      # Fallback: buscar por payment_intent_id si no hay metadata
      Transaction.find_by(payment_intent_id: payment_intent.id)
    end
    return unless transaction
    return if transaction.failed?

    transaction.update!(status: :failed)
  end

  def create_reservation_from_payment(payment_intent, transaction)
    reservation = Reservation.create!(
      user: transaction.user,
      class_session_id: payment_intent.metadata["class_session_id"],
      class_space_id: payment_intent.metadata["class_space_id"]
    )
    class_space = ClassSpace.find_by(id: payment_intent.metadata["class_space_id"])
    class_space.update!(status: :reserved)
    transaction.update!(reference: reservation, reference_type: "Reservation")

    if payment_intent.metadata["coupon_code"].present?
      coupon = Coupon.find_by(code: payment_intent.metadata["coupon_code"])
      if coupon
        service = Coupons::FinalizeUsageService.new(
          coupon: coupon,
          user: transaction.user,
          transaction: transaction,
          reservation: reservation
        )

        result = service.call

        unless result[:success]
          Rails.logger.error "Error al finalizar uso del cupón: #{result[:message]}"
        end
      end
    end
  rescue => e
    Rails.logger.error "Error al crear la reserva desde pago: #{e.message}"
  end

  # Ejemplo: para futuras expansiones
  def activate_membership(transaction)
    _user = transaction.user
    # Aquí podrías marcar su suscripción como activa
  end

  def assign_package_to_user(transaction)
    user = transaction.user
    class_package = transaction.reference

    return unless user && class_package.is_a?(ClassPackage)

    UserClassPackage.create!(
      user: user,
      class_package: class_package,
      remaining_classes: class_package.unlimited? ? nil : class_package.class_count,
      purchased_at: Time.current,
      status: "active",
      expires_at: class_package.unlimited? ? Time.current + class_package.expires_in_days.days : nil
    )
  end
end
