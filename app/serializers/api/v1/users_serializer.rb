class Api::V1::UsersSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :last_name, :phone, :role, :gender, :birthdate, :profile_picture_url, :has_injuries, :active_user_class_packages, :next_reservation

  has_many :injuries
  has_many :user_class_packages
  has_many :reservations
  has_many :transactions
  has_many :devices

  def profile_picture_url
    object.profile_picture.attached? ? object.profile_picture.url : nil
  end

  def has_injuries
    object.has_injuries.humanize
  end

  def active_user_class_packages
    object.user_class_packages.active ? object.user_class_packages.active : "Sin paquetes activos"
  end

  def next_reservation
    next_reservation = object.reservations
                             .active
                             .joins(:class_session)
                             .where("class_sessions.start_time >= ?", Time.current)
                             .order("class_sessions.start_time ASC")
                             .first

    next_reservation || nil
  end
end
