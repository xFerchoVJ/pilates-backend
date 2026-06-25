class ClassCreditAdjustment < ApplicationRecord
  belongs_to :user
  belongs_to :admin_user, class_name: "User", optional: true

  validates :amount, numericality: { only_integer: true, other_than: 0 }
  validates :reason, presence: true
end
