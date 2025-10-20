FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 6) }
    phone { Faker::PhoneNumber.phone_number }
    role { User.roles.keys.sample }
    gender { User.genders.keys.sample }
    birthdate { Faker::Date.birthday(min_age: 18, max_age: 65) }
    has_injuries { User.has_injuries.keys.sample }
  end
end
