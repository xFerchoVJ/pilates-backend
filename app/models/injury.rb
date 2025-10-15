class Injury < ApplicationRecord
  belongs_to :user

  validates :injury_type, presence: true
  validates :recovered, inclusion: { in: [ true, false ] }
  validates :severity, inclusion: { in: %w[leve moderada grave], message: "%{value} no es una severidad válida, debe ser leve, moderada o grave" }, allow_blank: true

  # Query scopes for filtering
  scope :search_text, ->(term) {
    t = "%#{term}%"
    where("injury_type ILIKE ? OR description ILIKE ?", t, t)
  }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_severity, ->(severity_value) { where(severity: severity_value) }
  scope :by_recovered, ->(value) { where(recovered: ActiveModel::Type::Boolean.new.cast(value)) }
  scope :occurred_from, ->(date) { where("date_ocurred >= ?", date.beginning_of_day) }
  scope :occurred_to, ->(date) { where("date_ocurred <= ?", date.end_of_day) }
end
