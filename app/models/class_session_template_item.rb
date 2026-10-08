class ClassSessionTemplateItem < ApplicationRecord
  belongs_to :class_session_template, inverse_of: :items
  belongs_to :instructor, class_name: "User"
  belongs_to :lounge

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :name, :start_time, :end_time, :instructor_id, :lounge_id, :price, presence: true
  validates :price, numericality: { greater_than: 0 }
  validate :end_after_start
  validate :instructor_is_instructor

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "debe ser después de la hora de inicio") if end_time <= start_time
  end

  def instructor_is_instructor
    return if instructor_id.blank?
    errors.add(:instructor, "debe ser instructor") unless instructor&.instructor?
  end
end
