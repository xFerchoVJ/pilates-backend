module Filters
  class ClassCreditsFilter
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
      filtered = filtered.by_reservation(@params[:reservation_id]) if present?(:reservation_id)
      filtered = filtered.by_status(@params[:status]) if present?(:status)
      filtered = filtered.used_from(@params[:used_from]) if present?(:used_from)
      filtered = filtered.used_to(@params[:used_to]) if present?(:used_to)

      if present?(:used_from)
        date = parse_date(@params[:used_from])
        filtered = filtered.used_from(date) if date
      end

      if present?(:used_to)
        date = parse_date(@params[:used_to])
        filtered = filtered.used_to(date) if date
      end
      filtered
    end

    private

    def present?(key)
      value = @params[key]
      value.present?
    end
  end
end
