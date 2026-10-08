class Api::V1::ClassSessionTemplateItemSerializer < ActiveModel::Serializer
  attributes :id, :day_of_week, :start_time, :end_time, :name, :description, :instructor_id, :lounge_id, :price

  def start_time
    object.start_time&.strftime("%H:%M")
  end

  def end_time
    object.end_time&.strftime("%H:%M")
  end
end
