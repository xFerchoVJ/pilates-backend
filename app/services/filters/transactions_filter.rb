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
      filtered = apply_order(filtered)

      filtered
    end

    private

    def apply_order(relation)
      sort = @params[:sort].presence || "created_at"
      direction = @params[:direction].to_s.downcase == "desc" ? :desc : :asc

      return relation unless allowed_sort_columns.include?(sort)

      relation.reorder(sort => direction)
    end

    def allowed_sort_columns
      %w[created_at updated_at amount status transaction_type]
    end

    def present?(key)
      value = @params[key]
      value.present?
    end
  end
end
