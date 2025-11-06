class Api::V1::ClassPackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :class_count, :price, :currency, :status
end
