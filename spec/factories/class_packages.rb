FactoryBot.define do
  factory :class_package do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    class_count { Faker::Number.between(from: 1, to: 10) }
    price { Faker::Number.between(from: 100, to: 1000) }
    currency { "MXN" }
    status { Faker::Boolean.boolean }
  end
end
