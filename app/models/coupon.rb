class Coupon < ApplicationRecord
  has_many :coupon_usages, dependent: :restrict_with_exception

  enum discount_type: { percentage: "percentage", fixed: "fixed" }

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :discount_type, inclusion: { in: discount_types.keys }
  validates :discount_value, numericality: { greater_than: 0 }

  scope :active_now, -> { where(active: true).where("starts_at IS NULL OR starts_at <= ?", Time.current).where("ends_at IS NULL OR ends_at >= ?", Time.current) }
  scope :search_text, ->(text) { where("code ILIKE ?", "%#{text}%") }
  scope :by_only_new_users, ->(only_new_users) { where(only_new_users: only_new_users) }

  def usable_for?(user: nil)
    unless active
      Rails.logger.error "Coupon #{code} is not active"
      return false
    end
    if starts_at.present? && Time.current < starts_at
      Rails.logger.error "Coupon #{code} is not active yet"
      return false
    end
    if ends_at.present? && Time.current > ends_at
      Rails.logger.error "Coupon #{code} has expired"
      return false
    end
    if only_new_users? && user.present?
      if user.is_new == false
        Rails.logger.error "Coupon #{code} is not valid for this user because they are not new"
        return false
      end
    end

    if usage_limit.present? && times_used >= usage_limit
      Rails.logger.error "Coupon #{code} has reached its usage limit"
      return false
    end

    if usage_limit_per_user.present? && user.present?
      if user.coupon_usages.where(coupon_id: id).count >= usage_limit_per_user
        Rails.logger.error "Coupon #{code} has reached its usage limit for this user"
        return false
      end
    end

    Rails.logger.info "Coupon #{code} is valid for user #{user.id}"
    true
  end

  def remaining_global_uses
    return Float::INFINITY if usage_limit.blank?
    [ usage_limit - times_used, 0 ].max
  end

  def remaining_for_user(user)
    return Float::INFINITY unless usage_limit_per_user.present?
    already = coupon_usages.where(user_id: user.id).count
    [ usage_limit_per_user - already, 0 ].max
  end
end
