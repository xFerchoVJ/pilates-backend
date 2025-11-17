class Api::V1::ClassSessionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :start_time, :end_time, :spots_left, :users_for_class, :users_count_for_class, :price
  has_one :instructor, serializer: Api::V1::UsersSerializer
  belongs_to :lounge, serializer: Api::V1::LoungesSerializer
  has_many :class_spaces

  def start_time
    object.start_time&.in_time_zone("America/Mexico_City")&.iso8601
  end

  def end_time
    object.end_time&.in_time_zone("America/Mexico_City")&.iso8601
  end

  def spots_left
    object.spots_left
  end

  def users_for_class
    object.reservations.includes(:user, :class_space).map do |reservation|
      {
        id: reservation.user.id,
        name: reservation.user.name,
        last_name: reservation.user.last_name,
        email: reservation.user.email,
        phone: reservation.user.phone,
        class_space_id: reservation.class_space.id,
        class_space_label: reservation.class_space.label,
        class_space_x: reservation.class_space.x,
        class_space_y: reservation.class_space.y,
        status: reservation.status
      }
    end
  end

  def users_count_for_class
    object.reservations.count
  end
end
