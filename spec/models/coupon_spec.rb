require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      coupon = build(:coupon)
      expect(coupon).to be_valid
    end

    it 'is not valid without a code' do
      coupon = build(:coupon, code: nil)
      expect(coupon).to be_invalid
      expect(coupon.errors[:code]).to include("can't be blank")
    end

    it 'is not valid with a duplicate code' do
      coupon = create(:coupon)
      duplicate = build(:coupon, code: coupon.code)
      expect(duplicate).to be_invalid
      expect(duplicate.errors[:code]).to include("has already been taken")
    end

    it 'raises an error with a discount type that is not valid' do
      coupon = build(:coupon)
      expect {
        coupon.discount_type = "invalid_type"
      }.to raise_error(ArgumentError)
    end

    it 'is not valid with a discount value that is not a number' do
      coupon = build(:coupon, discount_value: "invalid")
      expect(coupon).to be_invalid
      expect(coupon.errors[:discount_value]).to include("is not a number")
    end

    it 'is not valid with a discount value that is less than 0' do
      coupon = build(:coupon, discount_value: -1)
      expect(coupon).to be_invalid
      expect(coupon.errors[:discount_value]).to include("must be greater than 0")
    end
  end

  describe 'scopes' do
    it 'returns active coupons' do
      coupon = create(:coupon, active: true, starts_at: 1.hour.ago, ends_at: 1.hour.from_now)
      expect(Coupon.active_now).to include(coupon)
    end

    it 'returns inactive coupons' do
      coupon = create(:coupon, active: false)
      expect(Coupon.active_now).not_to include(coupon)
    end

    it "searches for coupons by code" do
      coupon = create(:coupon, code: "TEST123")
      expect(Coupon.search_text("TEST123")).to include(coupon)
    end

    it "searches for coupons by only new users" do
      coupon = create(:coupon, only_new_users: true)
      expect(Coupon.by_only_new_users(true)).to include(coupon)
    end
  end
end
