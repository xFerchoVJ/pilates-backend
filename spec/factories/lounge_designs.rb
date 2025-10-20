FactoryBot.define do
  factory :lounge_design do
    name { Faker::Lorem.words(number: 2).join(" ") }
    description { Faker::Lorem.sentence }
    layout_json {
      {
        "spaces" => Array.new(5) do |i|
          {
            "label" => (i + 1).to_s,
            "x" => Faker::Number.between(from: 50, to: 400),
            "y" => Faker::Number.between(from: 50, to: 400)
          }
        end
      }
    }
  end
end
