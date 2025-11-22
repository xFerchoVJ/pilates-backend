class Coupons::FinalizeUsageService
  def initialize(coupon:, user:, transaction:, reservation: nil, metadata: {})
    @coupon = coupon
    @user = user
    @transaction = transaction
    @reservation = reservation
    @metadata = metadata
  end

  def call
    Rails.logger.info "Finalizando uso del cupón: #{@coupon.inspect}"
    return failure("No cupón") unless @coupon
    return failure("No se encontró el cupón") unless @coupon.persisted?

    existing = CouponUsage.where(coupon: @coupon, transaction: @transaction).first
    return failure("El cupón ya ha sido usado") if existing.present?

    CouponUsage.create!(
      coupon: @coupon,
      user: @user,
      transaction: @transaction,
      reservation: @reservation,
      metadata: @metadata
    )

    # increment counter safely
    @coupon.class.transaction do
      @coupon.lock!
      @coupon.increment!(:times_used)
    end

    Rails.logger.info "Cupón finalizado correctamente"
    { success: true }
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error al finalizar uso del cupón: #{e.message}"
    failure("Error interno.")
  rescue => e
    Rails.logger.error "Error al finalizar uso del cupón: #{e.message}"
    failure("Error interno.")
  end

  private

  def failure(message)
    { success: false, message: message }
  end
end
