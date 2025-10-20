class LoungeDesign < ApplicationRecord
  has_many :lounges, dependent: :destroy

  validates :name, presence: true
  validates :layout_json, presence: true
end
