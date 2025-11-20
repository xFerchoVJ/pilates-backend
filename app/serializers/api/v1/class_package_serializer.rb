class Api::V1::ClassPackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :class_count, :price, :currency, :status, :unlimited, :expires_in_days, :daily_limit
end
