require 'rails_helper'

RSpec.describe ClassWaitlistNotification, type: :model do
  describe "validations" do
    it 'is valid with valid attributes' do
      class_waitlist_notification = build(:class_waitlist_notification)
      expect(class_waitlist_notification).to be_valid
    end

    it 'is not valid without a class session' do
      class_waitlist_notification = build(:class_waitlist_notification, class_session: nil)
      expect(class_waitlist_notification).to be_invalid
    end

    it 'is not valid without a user' do
      class_waitlist_notification = build(:class_waitlist_notification, user: nil)
      expect(class_waitlist_notification).to be_invalid
    end

    it 'is not valid with a duplicate class session and user' do
      class_waitlist_notification = create(:class_waitlist_notification)
      duplicate_class_waitlist_notification = build(:class_waitlist_notification, class_session: class_waitlist_notification.class_session, user: class_waitlist_notification.user)
      expect(duplicate_class_waitlist_notification).to be_invalid
    end
  end

  describe "associations" do
    it 'belongs to a class session' do
      class_waitlist_notification = create(:class_waitlist_notification)
      expect(class_waitlist_notification.class_session).to be_a(ClassSession)
    end

    it 'belongs to a user' do
      class_waitlist_notification = create(:class_waitlist_notification)
      expect(class_waitlist_notification.user).to be_a(User)
    end
  end
end
