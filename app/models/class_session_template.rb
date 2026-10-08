class ClassSessionTemplate < ApplicationRecord
  STATUSES = %w[active archived].freeze

  has_many :items,
           class_name: "ClassSessionTemplateItem",
           dependent: :destroy,
           inverse_of: :class_session_template
  has_many :publications,
           class_name: "ClassSessionTemplatePublication",
           dependent: :restrict_with_error

  accepts_nested_attributes_for :items, allow_destroy: true

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }
end
