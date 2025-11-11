FactoryBot.define do
  factory :device do
    user { create(:user) }
    expo_push_token { Faker::Internet.uuid }
  end
end
