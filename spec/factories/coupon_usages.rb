FactoryBot.define do
  factory :coupon_usage do
    coupon { nil }
    user { nil }
    reservation { nil }
    metadata { "" }
  end
end
