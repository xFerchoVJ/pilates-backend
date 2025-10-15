class Api::V1::UsersSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :last_name, :phone, :role, :gender, :birthdate, :profile_picture_url, :has_injuries

  has_many :injuries

  def profile_picture_url
    object.profile_picture.attached? ? object.profile_picture.url : nil
  end

  def has_injuries
    object.has_injuries.humanize
  end
end
