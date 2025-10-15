class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :class_session

  validates :user_id, uniqueness: { scope: :class_session_id, message: "ya tiene una reserva para esta clase" }
  validates :user_id, :class_session_id, presence: true

  validate :class_session_not_full

  # Query scopes for filtering
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_class_session, ->(class_session_id) { where(class_session_id: class_session_id) }
  scope :created_from, ->(date) { where("reservations.created_at >= ?", date.beginning_of_day) }
  scope :created_to, ->(date) { where("reservations.created_at <= ?", date.end_of_day) }

  private

  def class_session_not_full
    errors.add(:class_session, "La clase está llena") if class_session.full?
  end
end
