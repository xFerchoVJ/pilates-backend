module Filters
  class ClassPackagesFilter
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
      filtered = filtered.by_status(@params[:status]) if present?(:status)
      filtered = filtered.by_currency(@params[:currency]) if present?(:currency)
      filtered = filtered.price_min(@params[:price_min]) if present?(:price_min)
      filtered = filtered.price_max(@params[:price_max]) if present?(:price_max)
      filtered = filtered.class_count_min(@params[:class_count_min]) if present?(:class_count_min)
      filtered = filtered.class_count_max(@params[:class_count_max]) if present?(:class_count_max)
      filtered = filtered.unlimited if present?(:unlimited) && truthy?(@params[:unlimited])
      filtered = filtered.limited if present?(:limited) && truthy?(@params[:limited])

      if present?(:date_from)
        date = parse_date(@params[:date_from])
        filtered = filtered.created_from(date) if date
      end

      if present?(:date_to)
        date = parse_date(@params[:date_to])
        filtered = filtered.created_to(date) if date
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

    def truthy?(value)
      return false if value.nil?
      return true if value == true
      return true if value.is_a?(String) && %w[true 1 yes].include?(value.downcase)
      false
    end
  end
end
