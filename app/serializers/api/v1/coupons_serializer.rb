class Api::V1::CouponsSerializer < ActiveModel::Serializer
  attributes :id, :code, :discount_type, :discount_value, :usage_limit, :usage_limit_per_user, :only_new_users, :active, :starts_at, :ends_at, :metadata, :times_used
end
