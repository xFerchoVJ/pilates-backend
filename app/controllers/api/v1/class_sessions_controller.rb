class Api::V1::ClassSessionsController < ApplicationController
  include Filterable
  before_action :authenticate_user!
  before_action :set_class_session, only: %i[ show update destroy ]

  # GET /class_sessions
  def index
    # Define base scope based on user role
    @class_sessions = if current_user.respond_to?(:admin?) && current_user.admin?
                        ClassSession.all
    else
                        ClassSession.visible_to_customers
    end

    @class_sessions = @class_sessions.includes(:instructor, :reservations).order(:start_time)

    # Apply filters via service
    @class_sessions = ::Filters::ClassSessionsFilter.call(@class_sessions, filter_params)

    # Apply pagination
    @class_sessions = paginate_collection(@class_sessions, page: params[:page], per_page: params[:per_page])

    authorize @class_sessions
    render json: {
      class_sessions: ActiveModelSerializers::SerializableResource.new(
        @class_sessions,
        each_serializer: Api::V1::ClassSessionSerializer
      ),
      pagination: pagination_metadata(@class_sessions)
    }
  end

  # GET /class_sessions/1
  def show
    authorize @class_session
    render json: @class_session, serializer: Api::V1::ClassSessionSerializer
  end

  # POST /class_sessions
  def create
    @class_session = ClassSession.new(class_session_params)
    authorize @class_session
    if @class_session.save
      render json: @class_session, status: :created, serializer: Api::V1::ClassSessionSerializer
    else
      render json: @class_session.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /class_sessions/1
  def update
    authorize @class_session
    if @class_session.update(class_session_params)
      render json: @class_session, serializer: Api::V1::ClassSessionSerializer, status: :ok
    else
      render json: @class_session.errors, status: :unprocessable_entity
    end
  end

  # DELETE /class_sessions/1
  def destroy
    authorize @class_session
    @class_session.soft_delete!
  end

  def create_recurring
    authorize ClassSession, :create_recurring?
    days = params[:days_of_week] || []
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    sessions = ClassSessions::RecurringCreator.call(
      base_params: class_session_params,
      days_of_week: days.map(&:to_i),
      start_date: start_date,
      end_date: end_date
    )

    render json: {
      created: sessions.count,
      sessions: ActiveModelSerializers::SerializableResource.new(sessions, each_serializer: Api::V1::ClassSessionSerializer)
    }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_class_session
      @class_session = ClassSession.find(params[:id])
    end

    def filter_params
      params.permit(:instructor_id, :capacity_min, :capacity_max, :date_from, :date_to, :start_time_from, :start_time_to, :search, :lounge_id, :price_min, :price_max)
    end

    # Only allow a list of trusted parameters through.
    def class_session_params
      params.require(:class_session).permit(:name, :description, :start_time, :end_time, :instructor_id, :lounge_id, :price)
    end
end
