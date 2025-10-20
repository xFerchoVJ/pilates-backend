class ClassSession < ApplicationRecord
  belongs_to :instructor, class_name: "User"
  has_many :reservations, dependent: :destroy
  has_many :class_spaces, dependent: :destroy
  belongs_to :lounge

  validates :name, :start_time, :end_time, :instructor_id, :lounge_id, presence: true

  validate :end_after_start
  validate :user_is_instructor

  after_create :create_class_spaces

  def spots_left
    class_spaces.where(status: :available).count
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
  scope :capacity_min, ->(min) { where("class_spaces.count >= ?", min.to_i) }
  scope :capacity_max, ->(max) { where("class_spaces.count <= ?", max.to_i) }
  scope :by_lounge, ->(lounge_id) { where(lounge_id: lounge_id) }
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

  def create_class_spaces
    design = lounge.lounge_design
    return unless design&.layout_json&.dig("spaces")

    design.layout_json["spaces"].each do |space|
      class_spaces.create!(
        label: space["label"],
        x: space["x"],
        y: space["y"],
      )
    end
  end
end
