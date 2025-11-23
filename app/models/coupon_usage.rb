class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :user
  belongs_to :payment_transaction, class_name: "Transaction", foreign_key: "transaction_id", optional: true

  validates :coupon_id, :user_id, presence: true
end
