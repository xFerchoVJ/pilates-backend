class Api::V1::ClassWaitlistNotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_class_session, only: %i[ create destroy ]
  include Filterable

  def index
    @class_waitlist_notifications = ClassWaitlistNotification.all
    # Apply filters via service
    @class_waitlist_notifications = ::Filters::ClassWaitlistNotificationFilter.call(@class_waitlist_notifications, filter_params)

    # Apply pagination
    @class_waitlist_notifications = paginate_collection(@class_waitlist_notifications, page: params[:page], per_page: params[:per_page])

    authorize @class_waitlist_notifications
    render json: {
      class_waitlist_notifications: ActiveModelSerializers::SerializableResource.new(
        @class_waitlist_notifications,
        each_serializer: Api::V1::ClassWaitlistNotificationSerializer
      ),
      pagination: pagination_metadata(@class_waitlist_notifications)
    }
  end

  # POST /class_waitlist_notifications
  def create
    @class_waitlist_notification = ClassWaitlistNotification.find_or_create_by!(
      user: current_user,
      class_session: @class_session
    )
    authorize @class_waitlist_notification
    render json: @class_waitlist_notification, serializer: Api::V1::ClassWaitlistNotificationSerializer, status: :created
  end

  # DELETE /class_waitlist_notifications/1
  def destroy
    @class_waitlist_notification = ClassWaitlistNotification.find_by(
      user: current_user,
      class_session: @class_session
    )
    authorize @class_waitlist_notification
    @class_waitlist_notification&.destroy
    render json: { success: true }, status: :no_content
  end

  private
    def set_class_session
      @class_session = ClassSession.find(params[:class_session_id])
    end

    def filter_params
      params.permit(:user_id, :class_session_id, :notified_from, :notified_to)
    end
end
