class Api::V1::TransactionSerializer < ActiveModel::Serializer
  attributes :id, :amount, :currency, :status, :transaction_type, :reference, :reference_type, :payment_intent_id, :metadata, :created_at, :updated_at

  belongs_to :user
  belongs_to :reference, polymorphic: true
end
