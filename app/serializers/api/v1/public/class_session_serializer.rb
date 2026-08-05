class Api::V1::Public::ClassSessionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :start_time, :end_time, :price, :spots_left, :instructor, :lounge

  def start_time
    object.start_time&.in_time_zone&.iso8601
  end

  def end_time
    object.end_time&.in_time_zone&.iso8601
  end

  def instructor
    {
      id: object.instructor.id,
      name: object.instructor.name,
      last_name: object.instructor.last_name
    }
  end

  def lounge
    {
      id: object.lounge.id,
      name: object.lounge.name,
      description: object.lounge.description
    }
  end
end
