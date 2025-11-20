module Filters
  class ClassWaitlistNotificationFilter
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
      filtered = filtered.by_class_session(@params[:class_session_id]) if present?(:class_session_id)
      filtered = filtered.notified_from(@params[:notified_from]) if present?(:notified_from)
      filtered = filtered.notified_to(@params[:notified_to]) if present?(:notified_to)

      if present?(:notified_from)
        date = parse_date(@params[:notified_from])
        filtered = filtered.notified_from(date) if date
      end

      if present?(:notified_to)
        date = parse_date(@params[:notified_to])
        filtered = filtered.notified_to(date) if date
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
