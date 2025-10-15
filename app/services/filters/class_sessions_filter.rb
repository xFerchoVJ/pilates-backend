module Filters
  class ClassSessionsFilter
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
      filtered = filtered.by_instructor(@params[:instructor_id]) if present?(:instructor_id)
      filtered = filtered.capacity_min(@params[:capacity_min]) if present?(:capacity_min)
      filtered = filtered.capacity_max(@params[:capacity_max]) if present?(:capacity_max)

      if present?(:date_from)
        date = parse_date(@params[:date_from])
        filtered = filtered.date_from(date) if date
      end

      if present?(:date_to)
        date = parse_date(@params[:date_to])
        filtered = filtered.date_to(date) if date
      end

      filtered = filtered.start_time_from(@params[:start_time_from]) if present?(:start_time_from)
      filtered = filtered.start_time_to(@params[:start_time_to]) if present?(:start_time_to)

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
