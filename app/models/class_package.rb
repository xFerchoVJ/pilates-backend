class ClassPackage < ApplicationRecord
  has_many :user_class_packages, dependent: :destroy

  validates :name, :class_count, :price, :currency, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :class_count, numericality: { greater_than: 0 }

  scope :active, -> { where(status: true) }
  scope :inactive, -> { where(status: false) }
  scope :search_text, ->(term) {
    t = "%#{term}%"
    where("name ILIKE ? OR description ILIKE ?", t, t)
  }
  scope :by_status, ->(status) {
    status_value = status.to_s.downcase
    where(status: status_value == "true" || status_value == "1")
  }
  scope :by_currency, ->(currency) { where(currency: currency) }
  scope :price_min, ->(min) { where("price >= ?", min.to_i) }
  scope :price_max, ->(max) { where("price <= ?", max.to_i) }
  scope :class_count_min, ->(min) { where("class_count >= ?", min.to_i) }
  scope :class_count_max, ->(max) { where("class_count <= ?", max.to_i) }
  scope :created_from, ->(date) { where("created_at >= ?", date.beginning_of_day) }
  scope :created_to, ->(date) { where("created_at <= ?", date.end_of_day) }
end
