class Api::V1::ClassWaitlistNotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_class_session, only: %i[ create destroy ]

  # POST /class_waitlist_notifications
  def create
    @class_waitlist_notification = ClassWaitlistNotification.find_or_create_by!(
      user: current_user,
      class_session: @class_session
    )
    render json: @class_waitlist_notification, status: :created
  end

  # DELETE /class_waitlist_notifications/1
  def destroy
    record = ClassWaitlistNotification.find_by(
      user: current_user,
      class_session: @class_session
    )
    record&.destroy
    render json: { success: true }
  end

  private
    def set_class_session
      @class_session = ClassSession.find(params[:class_session_id])
    end
end
