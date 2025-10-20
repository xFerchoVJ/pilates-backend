class Api::V1::ReservationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :class_session_id, :created_at, :updated_at
  has_one :user, serializer: Api::V1::UsersSerializer
  has_one :class_session, serializer: Api::V1::ClassSessionSerializer
  has_one :class_space
end
