module Filters
  class LoungesFilter
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
      filtered = filtered.by_lounge_design(@params[:lounge_design_id]) if present?(:lounge_design_id)

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
  end
end
