FactoryBot.define do
  factory :lounge do
    name { Faker::Lorem.words(number: 2).join(" ") }
    description { Faker::Lorem.sentence }
    lounge_design { create(:lounge_design) }
  end
end
