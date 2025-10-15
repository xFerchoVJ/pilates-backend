module Filters
  class InjuriesFilter
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
      filtered = filtered.search_text(@params[:search]) if present?(:search)
      filtered = filtered.by_severity(@params[:severity]) if present?(:severity)
      filtered = filtered.by_recovered(@params[:recovered]) if present?(:recovered)

      if present?(:date_from)
        date = parse_date(@params[:date_from])
        filtered = filtered.occurred_from(date) if date
      end

      if present?(:date_to)
        date = parse_date(@params[:date_to])
        filtered = filtered.occurred_to(date) if date
      end

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
