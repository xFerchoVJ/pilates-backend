class Payments::PaymentIntentService
  def initialize(user:, amount:, currency:, transaction_type:, reference:, reference_type:, metadata:)
    @user = user
    @amount = amount
    @currency = currency
    @transaction_type = transaction_type
    @reference = reference
    @reference_type = reference_type
    @metadata = metadata
  end

  def call
    begin
      transaction = Transaction.new(
        user: @user,
        amount: @amount,
        currency: @currency,
        status: "pending",
        transaction_type: @transaction_type,
        reference: @reference,
        reference_type: @reference_type,
      )

      payment_intent = Stripe::PaymentIntent.create(
        amount: (@amount * 100).to_i,
        currency: @currency,
        metadata: @metadata.merge(
          { transaction_id: transaction.id }
        )
      )

      transaction.payment_intent_id = payment_intent.id
      transaction.save!

      success(client_secret: payment_intent.client_secret)
    rescue => e
      Rails.logger.error("Error creating payment intent: #{e.message}")
      failure("Error interno.")
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
