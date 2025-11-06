FactoryBot.define do
  factory :user_class_package do
    association :user
    association :class_package
    remaining_classes { Faker::Number.between(from: 0, to: 10) }
    status { "active" }
    purchased_at { Faker::Time.between(from: 1.year.ago, to: Time.current) }
  end
end
