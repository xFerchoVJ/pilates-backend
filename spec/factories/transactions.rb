FactoryBot.define do
  factory :transaction do
    user { create(:user) }
    amount { Faker::Commerce.price(range: 100.0..1000.0) }
    currency { "MXN" }
    transaction_type { %w[class_payment package_purchase subscription payment_refund].sample }
    reference { create(:class_session) }
    reference_type { "ClassSession" }
    payment_intent_id { Faker::Internet.uuid }
    metadata { { note: Faker::Lorem.sentence } }
    status { %w[pending succeeded failed refunded].sample }
  end
end
