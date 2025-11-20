class ClassCredit < ApplicationRecord
  belongs_to :user
  belongs_to :reservation

  enum status: { unused: "unused", used: "used" }

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_reservation, ->(reservation_id) { where(reservation_id: reservation_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :used_from, ->(date) { where("used_at >= ?", date.beginning_of_day) }
  scope :used_to, ->(date) { where("used_at <= ?", date.end_of_day) }
end
