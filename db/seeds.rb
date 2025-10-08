Injury.destroy_all
Reservation.destroy_all
ClassSession.destroy_all
User.destroy_all

# Crear 5 usuarios, 1 admin, 1 instructor, 3 users
users = 5.times.map do |i|
  User.create!(
    email: "user#{i+1}@example.com",
    password: "password",
    role: "user",
    name: "User #{i+1}",
    last_name: "User #{i+1}",
    phone: "1234567890",
    gender: "male",
    birthdate: "1990-01-01"
  )
end

admin = User.create!(
  email: "admin@example.com",
  password: "password",
  role: "admin",
  name: "Admin",
  last_name: "Admin",
  phone: "1234567890",
  gender: "male",
  birthdate: "1990-01-01"
)

instructor = User.create!(
  email: "instructor@example.com",
  password: "password",
  role: "instructor",
  name: "Instructor",
  last_name: "Instructor",
  phone: "1234567890",
  gender: "male",
  birthdate: "1990-01-01"
)
# Crear lesiones para los usuarios
users.each do |user|
  Injury.create!(
    user_id: user.id,
    injury_type: "Lesión de rodilla",
    description: "Dolor en la rodilla izquierda durante ejercicios de flexión",
    severity: "moderada",
    date_ocurred: "2024-01-15",
    recovered: false
  )
end

# Crear clases para el instructor
ClassSession.create!(
  instructor_id: instructor.id,
  name: "Clase de Pilates",
  description: "Clase de Pilates para principiantes",
  start_time: "2024-01-15 10:00:00",
  end_time: "2024-01-15 11:00:00",
  capacity: 3
)
