Injury.destroy_all
Reservation.destroy_all
ClassSession.destroy_all
User.destroy_all

# Crear 5 usuarios, 1 admin, 1 instructor, 3 users
users = 5.times.map do |i|
  User.create!(
    email: Faker::Internet.email,
    password: Faker::Internet.password,
    role: "user",
    name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone: Faker::PhoneNumber.phone_number,
    gender: User.genders.keys.sample,
    birthdate: Faker::Date.birthday(min_age: 18, max_age: 65)
  )
end

User.create!(
  email: Faker::Internet.email,
  password: "123456",
  role: "admin",
  name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  phone: Faker::PhoneNumber.phone_number,
  gender: User.genders.keys.sample,
  birthdate: Faker::Date.birthday(min_age: 18, max_age: 65)
)

instructor = User.create!(
  email: Faker::Internet.email,
  password: "123456",
  role: "instructor",
  name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  phone: Faker::PhoneNumber.phone_number,
  gender: User.genders.keys.sample,
  birthdate: Faker::Date.birthday(min_age: 18, max_age: 65)
)
# Crear lesiones para los usuarios
users.each do |user|
  Injury.create!(
    user_id: user.id,
    injury_type: Faker::Lorem.words(number: 2).join(" "),
    description: Faker::Lorem.sentence,
    severity: %w[leve moderada grave].sample,
    date_ocurred: Faker::Date.birthday(min_age: 18, max_age: 65),
    recovered: false
  )
end

design = LoungeDesign.create!(
  name: Faker::Lorem.words(number: 2).join(" "),
  description: Faker::Lorem.sentence,
  layout_json: {
    "spaces" => Array.new(5) do |i|
      {
        "label" => (i + 1).to_s,
        "x" => Faker::Number.between(from: 50, to: 400),
        "y" => Faker::Number.between(from: 50, to: 400)
      }
    end
  }
)
lounge = Lounge.create!(
  name: Faker::Lorem.words(number: 2).join(" "),
  description: Faker::Lorem.sentence,
  lounge_design_id: design.id
)

# Crear clases para el instructor
ClassSession.create!(
  instructor_id: instructor.id,
  name: Faker::Lorem.words(number: 2).join(" "),
  description: Faker::Lorem.sentence,
  start_time: Faker::Time.between(from: Time.current, to: Time.current + 1.hour),
  end_time: Faker::Time.between(from: Time.current + 1.hour, to: Time.current + 2.hours),
  lounge_id: lounge.id,
  price: Faker::Number.between(from: 100, to: 1000)
)
