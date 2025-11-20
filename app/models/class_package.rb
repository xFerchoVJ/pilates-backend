class ClassPackage < ApplicationRecord
  has_many :user_class_packages, dependent: :destroy

  validates :name, :class_count, :price, :currency, presence: true
  validates :price, numericality: { greater_than: 0 }

  validates :class_count, numericality: { greater_than: 0 }, unless: :unlimited?

  validate :unlimited_must_have_expiration

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
  scope :unlimited, -> { where(unlimited: true) }
  scope :limited, -> { where(unlimited: false) }

  def unlimited_must_have_expiration
    if unlimited? && expires_in_days.blank?
      errors.add(:expires_in_days, "debe tener una fecha de expiración")
    end

    if unlimited? && daily_limit.blank?
      errors.add(:daily_limit, "debe de tener un límite diario de clases")
    end
  end
end
