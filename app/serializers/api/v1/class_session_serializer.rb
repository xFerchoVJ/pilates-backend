class Api::V1::ClassSessionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :start_time, :end_time, :spots_left, :users_for_class
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
    object.reservations.includes(:user).map { |reservation| Api::V1::UsersSerializer.new(reservation.user) }
  end
end
