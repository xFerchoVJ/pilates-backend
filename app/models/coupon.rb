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
    return false unless active
    return false if starts_at.present? && Time.current < starts_at
    return false if ends_at.present? && Time.current > ends_at

    if only_new_users? && user.present?
      return false if Reservation.exists?(user_id: user.id)
    end

    if usage_limit.present? && times_used >= usage_limit
      return false
    end

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
