require 'rails_helper'

RSpec.describe Device, type: :model do
  describe "validations" do
    it 'is valid with valid attributes' do
      device = build(:device)
      expect(device).to be_valid
    end

    it 'is not valid without an expo push token' do
      device = build(:device, expo_push_token: nil)
      expect(device).to be_invalid
    end

    it 'is not valid without a user' do
      device = build(:device, user: nil)
      expect(device).to be_invalid
    end
  end

  describe "associations" do
    it 'belongs to a user' do
      device = create(:device)
      expect(device.user).to be_a(User)
    end
  end
end
