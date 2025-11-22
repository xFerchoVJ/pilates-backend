module Filters
  class CouponsFilter
    def self.call(relation, params)
      new(relation, params).call
    end

    def initialize(relation, params)
      @relation = relation
      @params = params || {}
    end

    def call
      filtered = @relation

      filtered = filtered.search_text(@params[:search]) if present?(:search)
      filtered = filtered.by_only_new_users(@params[:only_new_users]) if present?(:only_new_users)
      filtered = filtered.active_now if present?(:active_now)

      filtered
    end

    private

    def present?(key)
      value = @params[key]
      value.present?
    end

    def parse_date(value)
      Date.parse(value)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
