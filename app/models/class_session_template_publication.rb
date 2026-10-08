class ClassSessionTemplatePublication < ApplicationRecord
  belongs_to :class_session_template
  has_many :class_sessions,
           dependent: :nullify,
           inverse_of: :class_session_template_publication

  validates :week_start, presence: true
  validates :week_start, uniqueness: { scope: :class_session_template_id }
end
