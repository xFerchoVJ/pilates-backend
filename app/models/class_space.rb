class ClassSpace < ApplicationRecord
  belongs_to :class_session
  has_one :reservation, dependent: :destroy
  enum status: { available: 0, reserved: 1 }

  validates :label, presence: true
end
