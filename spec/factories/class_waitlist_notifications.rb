FactoryBot.define do
  factory :class_waitlist_notification do
    class_session { create(:class_session) }
    user { create(:user) }
    notified_at { nil }
  end
end
