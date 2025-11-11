class Device < ApplicationRecord
  belongs_to :user
  validates :expo_push_token, presence: true, uniqueness: true
end
