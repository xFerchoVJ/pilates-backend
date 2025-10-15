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

  # Query scopes for filtering
  scope :search_text, ->(term) {
    t = "%#{term}%"
    where("name ILIKE ? OR description ILIKE ?", t, t)
  }
  scope :by_instructor, ->(instructor_id) { where(instructor_id: instructor_id) }
  scope :capacity_min, ->(min) { where("capacity >= ?", min.to_i) }
  scope :capacity_max, ->(max) { where("capacity <= ?", max.to_i) }
  scope :start_time_from, ->(time) { where("start_time >= ?", parse_time(time)) }
  scope :start_time_to, ->(time) { where("start_time <= ?", parse_time(time)) }
  scope :date_from, ->(date) { where("start_time >= ?", date.beginning_of_day) }
  scope :date_to, ->(date) { where("start_time <= ?", date.end_of_day) }

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

  def self.parse_time(value)
    Time.parse(value)
  rescue ArgumentError, TypeError
    nil
  end
end
