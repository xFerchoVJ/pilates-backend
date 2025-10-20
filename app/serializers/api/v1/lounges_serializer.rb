class Api::V1::LoungesSerializer < ActiveModel::Serializer
  attributes :id, :name, :description

  belongs_to :lounge_design
  has_many :class_sessions
end
