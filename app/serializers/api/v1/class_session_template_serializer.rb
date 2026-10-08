class Api::V1::ClassSessionTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :status, :created_at, :updated_at

  has_many :items, serializer: Api::V1::ClassSessionTemplateItemSerializer
end
