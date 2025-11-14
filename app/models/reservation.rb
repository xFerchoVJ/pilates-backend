class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :class_session
  belongs_to :class_space

  validates :user_id, uniqueness: { scope: :class_session_id, message: "ya tiene una reserva para esta clase" }
  validates :user_id, :class_session_id, :class_space_id, presence: true
  validate :class_space_belongs_to_class_session
  validate :class_space_available
  validate :class_session_not_full
  validate :class_space_must_exist

  before_create :mark_space_as_reserved 
  after_destroy :mark_space_as_available

  private

  def class_space_belongs_to_class_session
    return if class_space.nil? || class_session_id.nil?
    unless class_space.class_session_id == class_session_id
      errors.add(:class_space, "no pertenece a esta clase")
    end
  end

  def class_space_available
    return if class_space.nil?
    if class_space.reserved?
      errors.add(:class_space, "ya está ocupado")
    end
  end

  def class_session_not_full
    return if class_session.nil?
    errors.add(:class_session, "La clase está llena") if class_session.full?
  end

  def class_space_must_exist
    # Ensure provided class_space_id references an existing ClassSpace
    if class_space_id.present? && class_space.nil?
      errors.add(:class_space, "no existe")
    end
  end

  def mark_space_as_reserved
    return if class_space.nil?
    class_space.update!(status: :reserved)
    UserMailer.reservation_confirmation(self).deliver_later
  end

  def mark_space_as_available
    return if class_space.nil?
    class_space.update!(status: :available)
    notifications = ClassWaitlistNotification
                      .where(class_session_id: class_session_id, notified_at: nil)
    notifications.find_each do |entry|
      tokens = entry.user.devices.pluck(:expo_push_token).compact
      next if tokens.empty?

      Notifications::PushNotificationsService.new(
        tokens: tokens,
        title: "¡Un lugar se liberó!",
        body: "Hay un lugar disponible en #{class_session.name}. ¡Reserva antes de que se acabe!"
      ).call

      entry.update!(notified_at: Time.current)
    end
  end
end
