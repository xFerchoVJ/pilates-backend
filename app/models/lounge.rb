class Lounge < ApplicationRecord
  belongs_to :lounge_design
  has_many :class_sessions, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

  scope :search_text, ->(term) {
    t = "%#{term}%"
    where("name ILIKE ? OR description ILIKE ?", t, t)
  }
  scope :by_lounge_design, ->(lounge_design_id) { where(lounge_design_id: lounge_design_id) }
  scope :created_from, ->(date) { where("created_at >= ?", date.beginning_of_day) }
  scope :created_to, ->(date) { where("created_at <= ?", date.end_of_day) }
end
