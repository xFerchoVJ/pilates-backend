class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :class_session

  validates :user_id, uniqueness: { scope: :class_session_id, message: "ya tiene una reserva para esta clase" }
  validates :user_id, :class_session_id, presence: true

  validate :class_session_not_full

  private

  def class_session_not_full
    errors.add(:class_session, "La clase está llena") if class_session.full?
  end
end
