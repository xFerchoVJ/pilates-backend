module Filters
  class UserClassPackagesFilter
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
      filtered = filtered.by_class_package(@params[:class_package_id]) if present?(:class_package_id)
      filtered = filtered.by_status(@params[:status]) if present?(:status)
      filtered = filtered.remaining_classes_min(@params[:remaining_classes_min]) if present?(:remaining_classes_min)
      filtered = filtered.remaining_classes_max(@params[:remaining_classes_max]) if present?(:remaining_classes_max)

      if present?(:purchased_from)
        date = parse_date(@params[:purchased_from])
        filtered = filtered.purchased_from(date) if date
      end

      if present?(:purchased_to)
        date = parse_date(@params[:purchased_to])
        filtered = filtered.purchased_to(date) if date
      end

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
