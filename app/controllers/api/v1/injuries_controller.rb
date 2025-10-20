class Api::V1::InjuriesController < ApplicationController
  include Filterable
  before_action :authenticate_user!
  before_action :set_injury, only: %i[ show update destroy ]

  # GET /api/v1/injuries
  def index
    @injuries = Injury.includes(:user).order(:created_at)

    # Apply filters via service
    @injuries = ::Filters::InjuriesFilter.call(@injuries, filter_params)

    # Apply pagination
    @injuries = paginate_collection(@injuries, page: params[:page], per_page: params[:per_page])

    authorize @injuries
    render json: {
      injuries: ActiveModelSerializers::SerializableResource.new(
        @injuries,
        each_serializer: Api::V1::InjuriesSerializer
      ),
      pagination: pagination_metadata(@injuries)
    }
  end

  # GET /api/v1/injuries/1
  def show
    authorize @injury
    render json: @injury, serializer: Api::V1::InjuriesSerializer
  end

  # POST /api/v1/injuries
  def create
    @injury = Injury.new(injury_params)
    authorize @injury

    if @injury.save
      render json: @injury, serializer: Api::V1::InjuriesSerializer, status: :created
    else
      render json: @injury.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/injuries/1
  def update
    authorize @injury
    if @injury.update(injury_params)
      render json: @injury, serializer: Api::V1::InjuriesSerializer
    else
      render json: @injury.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/injuries/1
  def destroy
    authorize @injury
    @injury.destroy!
  end


  def injuries_by_user
    return render json: { error: "No autorizado" }, status: :unauthorized unless @current_user&.admin? || @current_user&.id.to_s == params[:user_id] || @current_user&.instructor?

    @injuries = Injury.includes(:user).where(user_id: params[:user_id]).order(:created_at)

    # Apply filters via service
    @injuries = ::Filters::InjuriesFilter.call(@injuries, filter_params)

    # Apply pagination
    @injuries = paginate_collection(@injuries, page: params[:page], per_page: params[:per_page])

    render json: {
      injuries: ActiveModelSerializers::SerializableResource.new(
        @injuries,
        each_serializer: Api::V1::InjuriesSerializer
      ),
      pagination: pagination_metadata(@injuries)
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_injury
      @injury = Injury.find(params[:id])
    end

    def filter_params
      params.permit(:user_id, :injury_type, :severity, :recovered, :date_from, :date_to, :search)
    end

    # Only allow a list of trusted parameters through.
    def injury_params
      params.require(:injury).permit(:user_id, :injury_type, :description, :severity, :date_ocurred, :recovered)
    end
end
