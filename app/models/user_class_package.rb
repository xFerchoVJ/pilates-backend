class UserClassPackage < ApplicationRecord
  belongs_to :user
  belongs_to :class_package

  validates :remaining_classes, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(status: "active") }

  # Query scopes for filtering
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_class_package, ->(class_package_id) { where(class_package_id: class_package_id) }
  scope :by_status, ->(status) { where(status: status) }
  scope :remaining_classes_min, ->(min) { where("remaining_classes >= ?", min.to_i) }
  scope :remaining_classes_max, ->(max) { where("remaining_classes <= ?", max.to_i) }
  scope :purchased_from, ->(date) { where("purchased_at >= ?", date.beginning_of_day) }
  scope :purchased_to, ->(date) { where("purchased_at <= ?", date.end_of_day) }
  scope :created_from, ->(date) { where("created_at >= ?", date.beginning_of_day) }
  scope :created_to, ->(date) { where("created_at <= ?", date.end_of_day) }

  def consume_class!
    return if class_package.unlimited?
    decrement!(:remaining_classes)
    update!(status: "completed") if remaining_classes.zero?
  end
end
