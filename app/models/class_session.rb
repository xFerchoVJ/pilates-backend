class ClassSession < ApplicationRecord
  belongs_to :instructor, class_name: "User"
  has_many :reservations

  validates :name, :start_time, :end_time, :capacity, :instructor_id, presence: true
  validates :capacity, numericality: { greater_than: 0 }

  validate :end_after_start
  validate :user_is_instructor

  def spots_left
    capacity - reservations.count
  end

  def full?
    spots_left <= 0
  end

  private

  def end_after_start
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "debe ser después de la hora de inicio") if end_time <= start_time
  end

  def user_is_instructor
    return if instructor_id.blank?
    user = User.find_by(id: instructor_id)
    errors.add(:instructor, "debe ser instructor") unless user&.instructor?
  end
end
