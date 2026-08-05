class Api::V1::Public::ClassSessionsController < ApplicationController
  # GET /api/v1/public/class_sessions/schedule
  def schedule
    class_sessions = ClassSession.visible_to_customers
                                 .includes(:instructor, :lounge, :class_spaces)
                                 .where(start_time: schedule_range)
                                 .order(:start_time)

    render json: {
      class_sessions: ActiveModelSerializers::SerializableResource.new(
        class_sessions,
        each_serializer: Api::V1::Public::ClassSessionSerializer
      )
    }
  end

  private

    def schedule_range
      Time.zone.today.beginning_of_day..(Time.zone.today.end_of_day + 14.days)
    end
end
