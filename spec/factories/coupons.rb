FactoryBot.define do
  factory :coupon do
    code { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    discount_type { Coupon.discount_types.keys.sample }
    discount_value { Faker::Number.between(from: 1, to: 100) }
    usage_limit { 1 }
    usage_limit_per_user { 1 }
    only_new_users { Faker::Boolean.boolean }
    active { Faker::Boolean.boolean }
    starts_at { Faker::Time.between(from: Time.current, to: Time.current + 1.hour) }
    ends_at { Faker::Time.between(from: Time.current + 1.hour, to: Time.current + 2.hours) }
    metadata { { note: Faker::Lorem.sentence } }
  end
end
