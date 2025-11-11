FactoryBot.define do
  factory :class_session do
    name { Faker::Lorem.words(number: 2).join(" ") }
    description { Faker::Lorem.sentence }
    start_time { Faker::Time.between(from: Time.current, to: Time.current + 1.hour) }
    end_time { Faker::Time.between(from: start_time, to: start_time + 1.hour) }
    instructor { create(:user, role: 'instructor') }
    lounge { create(:lounge) }
    price { Faker::Number.between(from: 100, to: 1000) }
    after(:create) do |class_session|
      class_session.lounge.lounge_design.layout_json["spaces"].each do |space|
        ClassSpace.create!(
          class_session: class_session,
          label: space["label"],
          x: space["x"],
          y: space["y"]
        )
      end
    end
  end
end
