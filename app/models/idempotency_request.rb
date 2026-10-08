class IdempotencyRequest < ApplicationRecord
  RETENTION_PERIOD = 24.hours

  belongs_to :user
  has_one :payment_transaction,
          class_name: "Transaction",
          foreign_key: :idempotency_request_id,
          dependent: :nullify

  validates :key, :endpoint, :request_fingerprint, :status, :expires_at, presence: true
  validates :key, length: { maximum: 255 }
  validates :key, uniqueness: true

  enum status: {
    processing: "processing",
    completed: "completed"
  }
end
