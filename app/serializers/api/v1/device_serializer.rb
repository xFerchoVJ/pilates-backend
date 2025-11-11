class Api::V1::DeviceSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :expo_push_token

  has_one :user, serializer: Api::V1::UsersSerializer
end
