require 'rails_helper'

RSpec.describe LoungeDesign, type: :model do
  describe "validations" do
    it 'is valid with valid attributes' do
      design = build(:lounge_design)
      expect(design).to be_valid
    end

    it 'is not valid without a name' do
      design = build(:lounge_design, name: nil)
      expect(design).to be_invalid
      expect(design.errors[:name]).to include("can't be blank")
    end

    it 'is not valid without a layout_json' do
      design = build(:lounge_design, layout_json: nil)
      expect(design).not_to be_valid
    end
    it "is not valid if layout_json doesn't include spaces key" do
      design = build(:lounge_design, layout_json: { "foo" => [] })
      expect(design).not_to be_valid
      expect(design.errors[:layout_json]).to include("must includes 'spaces' array")
    end

    it "is not valid if spaces is not an array" do
      design = build(:lounge_design, layout_json: { "spaces" => "not an array" })
      expect(design).not_to be_valid
      expect(design.errors[:layout_json]).to include("must includes 'spaces' array")
    end

    it "is not valid if spaces elements are missing keys" do
      design = build(:lounge_design, layout_json: {
        "spaces" => [ { "label" => "1" } ] # faltan x e y
      })
      expect(design).not_to be_valid
      expect(design.errors[:layout_json]).to include("each space must include 'label', 'x', and 'y'")
    end
  end

  describe '#spaces' do
    it 'return the spaces from the layout_json' do
      design = build(:lounge_design)
      expect(design.layout_json["spaces"]).to be_an(Array)
      expect(design.layout_json["spaces"].first).to include("label", "x", "y")
    end
  end
end
