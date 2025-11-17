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
    active_packages = object.user_class_packages.active.includes(:class_package)

    return "Sin paquetes activos" if active_packages.empty?

    active_packages.map do |user_package|
      {
        id: user_package.id,
        user_id: user_package.user_id,
        class_package_id: user_package.class_package_id,
        remaining_classes: user_package.remaining_classes,
        status: user_package.status,
        purchased_at: user_package.purchased_at,
        class_package_name: user_package.class_package.name
      }
    end
  end

  def next_reservation
    next_reservation = object.reservations
                             .active
                             .joins(:class_session)
                             .where("class_sessions.start_time >= ?", Time.current)
                             .order("class_sessions.start_time ASC")
                             .first

    return nil if next_reservation.nil?

    {
      id: next_reservation.id,
      user_id: next_reservation.user_id,
      class_session_id: next_reservation.class_session_id,
      class_space_id: next_reservation.class_space_id,
      status: next_reservation.status,
      class_name: next_reservation.class_session.name,
      instructor_name: instructor_full_name(next_reservation.class_session.instructor),
      start_time: next_reservation.class_session.start_time,
      end_time: next_reservation.class_session.end_time
    }
  end


  private

  def instructor_full_name(instructor)
    "#{instructor.name} #{instructor.last_name}"
  end
end
