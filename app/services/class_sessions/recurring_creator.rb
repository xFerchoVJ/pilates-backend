module ClassSessions
  class RecurringCreator
    def self.call(base_params:, days_of_week:, start_date:, end_date:)
      created_sessions = []
      current_date = start_date.to_date

      while current_date <= end_date.to_date
        if days_of_week.include?(current_date.wday) # 0 = domingo, 1 = lunes...
          start_time = combine_date_and_time(current_date, base_params[:start_time])
          end_time   = combine_date_and_time(current_date, base_params[:end_time])

          session = ClassSession.create!(
            name: base_params[:name],
            description: base_params[:description],
            instructor_id: base_params[:instructor_id],
            lounge_id: base_params[:lounge_id],
            start_time: start_time,
            end_time: end_time,
            price: base_params[:price]
          )
          created_sessions << session
        end

        current_date += 1.day
      end

      created_sessions
    end

    def self.combine_date_and_time(date, time_string)
      # Parse time string (format: "HH:MM")
      hour, min = time_string.split(":").map(&:to_i)

      # Create datetime in the application's timezone
      Time.zone.parse("#{date} #{hour}:#{min}:00")
    end
  end
end
