FactoryBot.define do
  factory :class_credit do
    user { create(:user) }
    reservation { create(:reservation) }
    status { "unused" }
    used_at { nil }
  end
end
