class Api::V1::InjuriesSerializer < ActiveModel::Serializer
  attributes :id, :injury_type, :description, :severity, :date_ocurred, :recovered, :created_at, :updated_at
  belongs_to :user
end
