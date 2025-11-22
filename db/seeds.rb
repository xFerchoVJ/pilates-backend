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
    birthdate: Faker::Date.birthday(min_age: 18, max_age: 65),
    has_injuries: User.has_injuries.keys.sample
  )
end

User.create!(
  email: "admin@example.com",
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
# Crear lesiones para los usuarios que su status es yes
users.each do |user|
  next if user.has_injuries != "yes"
  Injury.create!(
    user: user,
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

# Crear clases
5.times.each do |i|
  ClassSession.create!(
    instructor_id: instructor.id,
    name: Faker::Lorem.words(number: 2).join(" "),
    description: Faker::Lorem.sentence,
    start_time: Faker::Time.between(from: Time.current, to: Time.current + 1.hour),
    end_time: Faker::Time.between(from: Time.current + 1.hour, to: Time.current + 2.hours),
    lounge_id: lounge.id,
    price: Faker::Number.between(from: 100, to: 1000)
  )
end

# Crear espacios para las clases
ClassSession.all.each do |class_session|
  ClassSpace.create!(
    class_session: class_session,
    label: Faker::Lorem.words(number: 2).join(" "),
    x: Faker::Number.between(from: 50, to: 400),
    y: Faker::Number.between(from: 50, to: 400)
  )
end

# Crear paquete de clases
5.times.each do |i|
  unlimited = Faker::Boolean.boolean
  expires_in_days = unlimited ? Faker::Number.between(from: 1, to: 30) : nil
  daily_limit = unlimited ? Faker::Number.between(from: 1, to: 10) : nil
  ClassPackage.create!(
    name: Faker::Lorem.words(number: 2).join(" "),
    description: Faker::Lorem.sentence,
    class_count: unlimited ? 0 : Faker::Number.between(from: 10, to: 100),
    price: Faker::Number.between(from: 100, to: 1000),
    currency: "mxn",
    status: true,
    unlimited: unlimited,
    expires_in_days: expires_in_days,
    daily_limit: daily_limit
  )
end

# Asignar aleatoriamente un paquete de clases a los usuarios
users.each do |user|
  class_package = ClassPackage.all.sample
  expires_at = class_package.expires_in_days ? class_package.expires_in_days.days.from_now : nil
  UserClassPackage.create!(
    user: user,
    class_package: class_package,
    remaining_classes: class_package.class_count,
    purchased_at: Time.current,
    status: "active",
    expires_at: expires_at
  )
end

# Crear reservas para los usuarios
users.each do |user|
  ClassSession.all.each do |class_session|
    next if Reservation.exists?(user: user, class_session: class_session)
    class_space = ClassSpace.where(class_session: class_session, status: :available).sample
    next if class_space.nil?
    Reservation.create!(
      user: user,
      class_session: class_session,
      class_space: class_space
    )
  end
end

# Crear cupones
5.times.each do |i|
  Coupon.create!(
    code: Faker::Alphanumeric.alphanumeric(number: 10).upcase,
    discount_type: Coupon.discount_types.keys.sample,
    discount_value: Faker::Number.between(from: 1, to: 100),
    usage_limit: Faker::Number.between(from: 1, to: 100),
    usage_limit_per_user: Faker::Number.between(from: 1, to: 100),
    only_new_users: Faker::Boolean.boolean,
    active: Faker::Boolean.boolean
  )
end
