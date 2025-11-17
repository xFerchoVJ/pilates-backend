class Api::V1::ClassSpaceSerializer < ActiveModel::Serializer
  attributes :id, :label, :x, :y, :status

  belongs_to :class_session

  def status
    object.status.humanize
  end
end
