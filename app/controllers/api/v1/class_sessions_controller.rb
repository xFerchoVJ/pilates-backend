class Api::V1::ClassSessionsController < ApplicationController
  include Filterable

  before_action :set_class_session, only: %i[ show update destroy ]

  # GET /class_sessions
  def index
    @class_sessions = ClassSession.includes(:instructor, :reservations).order(:start_time)

    # Apply filters via service
    @class_sessions = Filters::ClassSessionsFilter.call(@class_sessions, filter_params)

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
    @class_session.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_class_session
      @class_session = ClassSession.find(params[:id])
    end

    def filter_params
      params.permit(:instructor_id, :capacity_min, :capacity_max, :date_from, :date_to, :start_time_from, :start_time_to, :search)
    end

    # Only allow a list of trusted parameters through.
    def class_session_params
      params.require(:class_session).permit(:name, :description, :start_time, :end_time, :capacity, :instructor_id)
    end
end
