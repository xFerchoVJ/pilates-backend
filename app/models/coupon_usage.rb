class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :user
  belongs_to :reservation, optional: true
  belongs_to :transaction, optional: true

  validates :coupon_id, :user_id, presence: true
end
