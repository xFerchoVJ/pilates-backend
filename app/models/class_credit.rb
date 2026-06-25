class ClassCredit < ApplicationRecord
  belongs_to :user
  belongs_to :reservation, optional: true

  enum status: { unused: "unused", used: "used", voided: "voided" }

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_reservation, ->(reservation_id) { where(reservation_id: reservation_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :not_expired, -> { where("expires_at IS NULL OR expires_at >= ?", Time.current) }
  scope :used_from, ->(date) { where("used_at >= ?", date.beginning_of_day) }
  scope :used_to, ->(date) { where("used_at <= ?", date.end_of_day) }
end
