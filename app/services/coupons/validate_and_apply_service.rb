class Coupons::ValidateAndApplyService
  def initialize(coupon_code:, price_cents:, user: nil, context: {})
    @coupon_code = coupon_code.to_s.strip.upcase
    @price_cents = price_cents.to_i
    @user = user
    @context = context
  end

  def call
    return no_coupon unless @coupon_code.present?

    coupon = Coupon.find_by("upper(code) = ?", @coupon_code)
    return failure("Cupón no encontrado") unless coupon

    return failure("El cupón no está activo") unless coupon.active
    if coupon.starts_at.present? && Time.current < coupon.starts_at
      return failure("El cupón no está disponible todavía")
    end
    if coupon.ends_at.present? && Time.current > coupon.ends_at
      return failure("El cupón ha expirado")
    end

    unless coupon.usable_for?(user: @user)
      return failure("El cupón no es válido para este usuario")
    end

    if coupon.usage_limit.present? && coupon.times_used >= coupon.usage_limit
      return failure("El cupón ha alcanzado su límite de uso")
    end

    if coupon.usage_limit_per_user.present? && @user.present?
      used_by_user = coupon.coupon_usages.where(user_id: @user.id).count
      if used_by_user >= coupon.usage_limit_per_user
        return failure("Ya has usado este cupón el número máximo de veces")
      end
    end

    discount_cents = calculate_discount_cents(coupon)
    final_amount_cents = [ @price_cents - discount_cents, 0 ].max

    success(
      coupon: coupon,
      discount_cents: discount_cents,
      final_amount_cents: final_amount_cents
    )
  end

  private

  def calculate_discount_cents(coupon)
    if coupon.percentage?
      ((@price_cents * coupon.discount_value.to_d) / 100).to_i
    else
      coupon.discount_value.to_i
    end
  end

  def no_coupon
    { success: true, coupon: nil, discount_cents: 0, final_amount_cents: @price_cents }
  end

  def success(payload)
    { success: true }.merge(payload)
  end

  def failure(message)
    { success: false, message: message }
  end
end
