class Api::V1::LoungeDesignSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :layout_json

  def layout_json
    object.layout_json.to_json
  end
end
