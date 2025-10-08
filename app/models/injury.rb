class Injury < ApplicationRecord
  belongs_to :user

  validates :injury_type, presence: true
  validates :recovered, inclusion: { in: [ true, false ] }
  validates :severity, inclusion: { in: %w[leve moderada grave], message: "%{value} no es una severidad válida, debe ser leve, moderada o grave" }, allow_blank: true
end
