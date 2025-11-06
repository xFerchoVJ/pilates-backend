class Api::V1::UserClassPackageSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :class_package_id, :remaining_classes, :status, :purchased_at
  belongs_to :user, serializer: Api::V1::UsersSerializer
  belongs_to :class_package, serializer: Api::V1::ClassPackageSerializer
end
