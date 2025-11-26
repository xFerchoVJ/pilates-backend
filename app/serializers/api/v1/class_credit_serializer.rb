class Api::V1::ClassCreditSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :reservation_id, :status, :used_at, :user_email, :reservation_id

  def user_email
    object.user.email
  end

  def reservation_id
    object.reservation ? object.reservation.id : nil
  end
end
