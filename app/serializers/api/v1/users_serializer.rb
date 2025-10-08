class Api::V1::UsersSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :last_name, :phone, :role, :gender, :birthdate, :profile_picture_url

  has_many :injuries

  def profile_picture_url
    object.profile_picture.attached? ? object.profile_picture.url : nil
  end
end
