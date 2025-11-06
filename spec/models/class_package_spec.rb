require 'rails_helper'

RSpec.describe ClassPackage, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      class_package = build(:class_package)
      expect(class_package).to be_valid
    end

    it "is not valid without a name" do
      class_package = build(:class_package, name: nil)
      expect(class_package).to be_invalid
      expect(class_package.errors[:name]).to include("can't be blank")
    end

    it "is not valid without a class_count" do
      class_package = build(:class_package, class_count: nil)
      expect(class_package).to be_invalid
      expect(class_package.errors[:class_count]).to include("can't be blank")
    end

    it "is not valid without a price" do
      class_package = build(:class_package, price: nil)
      expect(class_package).to be_invalid
      expect(class_package.errors[:price]).to include("can't be blank")
    end

    it "is not valid without a currency" do
      class_package = build(:class_package, currency: nil)
      expect(class_package).to be_invalid
      expect(class_package.errors[:currency]).to include("can't be blank")
    end

    it "is not valid with a price less than 0" do
      class_package = build(:class_package, price: -1)
      expect(class_package).to be_invalid
      expect(class_package.errors[:price]).to include("must be greater than 0")
    end

    it "is not valid with a class_count less than 0" do
      class_package = build(:class_package, class_count: -1)
      expect(class_package).to be_invalid
      expect(class_package.errors[:class_count]).to include("must be greater than 0")
    end
  end

  describe "scopes" do
    it "returns active packages" do
      class_package = create(:class_package, status: true)
      expect(ClassPackage.active).to include(class_package)
    end

    it "returns inactive packages" do
      class_package = create(:class_package, status: false)
      expect(ClassPackage.inactive).to include(class_package)
    end

    it "returns packages by currency" do
      class_package = create(:class_package, currency: "MXN")
      expect(ClassPackage.by_currency("MXN")).to include(class_package)
    end

    it "returns packages by price min" do
      class_package = create(:class_package, price: 100)
      expect(ClassPackage.price_min(100)).to include(class_package)
    end

    it "returns packages by price max" do
      class_package = create(:class_package, price: 100)
      expect(ClassPackage.price_max(100)).to include(class_package)
    end

    it "returns packages by class_count min" do
      class_package = create(:class_package, class_count: 10)
      expect(ClassPackage.class_count_min(10)).to include(class_package)
    end

    it "returns packages by class_count max" do
      class_package = create(:class_package, class_count: 10)
      expect(ClassPackage.class_count_max(10)).to include(class_package)
    end

    it "returns packages by created_from" do
      class_package = create(:class_package, created_at: 1.day.ago)
      expect(ClassPackage.created_from(1.day.ago)).to include(class_package)
    end

    it "returns packages by created_to" do
      class_package = create(:class_package, created_at: 1.day.ago)
      expect(ClassPackage.created_to(1.day.ago)).to include(class_package)
    end

    it "returns packages by search text" do
      class_package = create(:class_package, name: "Test Package")
      expect(ClassPackage.search_text("Test Package")).to include(class_package)
    end

    it "returns packages by status" do
      class_package = create(:class_package, status: true)
      expect(ClassPackage.by_status(true)).to include(class_package)
    end
  end
end
