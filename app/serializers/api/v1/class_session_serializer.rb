class Api::V1::ClassSessionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :start_time, :end_time, :capacity, :spots_left
  has_one :instructor, serializer: Api::V1::UsersSerializer

  def start_time
    object.start_time&.in_time_zone("America/Mexico_City")&.iso8601
  end

  def end_time
    object.end_time&.in_time_zone("America/Mexico_City")&.iso8601
  end

  def spots_left
    object.capacity - object.reservations.count
  end
end
