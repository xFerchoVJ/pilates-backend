class LoungeDesign < ApplicationRecord
  has_many :lounges, dependent: :destroy

  validates :name, presence: true
  validates :layout_json, presence: true

  validate :layout_json_format

  private

  def layout_json_format
    unless layout_json.present?
      errors.add(:layout_json, "is required")
      return
    end

    unless layout_json.is_a?(Hash) && layout_json.key?("spaces")
      errors.add(:layout_json, "must includes 'spaces' array")
      return
    end

    spaces = layout_json["spaces"]
    unless spaces.is_a?(Array)
      errors.add(:layout_json, "must includes 'spaces' array")
      return
    end

    invalid_spaces = spaces.reject do |s|
      s.is_a?(Hash) && s.key?("label") && s.key?("x") && s.key?("y")
    end

    if invalid_spaces.any?
      errors.add(:layout_json, "each space must include 'label', 'x', and 'y'")
    end
  end
end
