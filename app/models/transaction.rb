class Transaction < ApplicationRecord
  belongs_to :user
  # reference is the model that the transaction is associated with
  belongs_to :reference, polymorphic: true

  validates :amount, :currency, :status, :transaction_type, presence: true


  validates :amount, numericality: { greater_than: 0 }, unless: -> { transaction_type == "class_redeemed" }

  enum status: {
    pending: "pending",
    succeeded: "succeeded",
    failed: "failed",
    refunded: "refunded"
  }

  enum transaction_type: {
    class_payment: "class_payment",
    package_purchase: "package_purchase",
    class_redeemed: "class_redeemed",
    class_credit_used: "class_credit_used"
  }

  # Query scopes for filtering
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_transaction_type, ->(transaction_type) { where(transaction_type: transaction_type) }

  def stripe_url
    "https://dashboard.stripe.com/payments/#{payment_intent_id}"
  end
end
