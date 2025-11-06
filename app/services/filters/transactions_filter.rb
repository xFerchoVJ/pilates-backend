module Filters
  class TransactionsFilter
    def self.call(relation, params)
      new(relation, params).call
    end

    def initialize(relation, params)
      @relation = relation
      @params = params || {}
    end

    def call
      filtered = @relation

      filtered = filtered.by_user(@params[:user_id]) if present?(:user_id)
      filtered = filtered.by_status(@params[:status]) if present?(:status)
      filtered = filtered.by_transaction_type(@params[:transaction_type]) if present?(:transaction_type)

      filtered
    end

    private

    def present?(key)
      value = @params[key]
      value.present?
    end
  end
end
