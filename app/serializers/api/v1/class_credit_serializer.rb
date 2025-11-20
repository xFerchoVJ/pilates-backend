class Api::V1::ClassCreditSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :reservation_id, :status, :used_at
  belongs_to :user, serializer: Api::V1::UsersSerializer
  belongs_to :reservation, serializer: Api::V1::ReservationSerializer
end
