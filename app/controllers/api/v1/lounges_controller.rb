class Api::V1::LoungesController < ApplicationController
  include Filterable
  before_action :authenticate_user!
  before_action :set_lounge, only: %i[ show update destroy ]

  # GET /lounges
  def index
    @lounges = Lounge.includes(:lounge_design, :class_sessions).order(:created_at)

    # Apply filters via service
    @lounges = ::Filters::LoungesFilter.call(@lounges, filter_params)

    # Apply pagination
    @lounges = paginate_collection(@lounges, page: params[:page], per_page: params[:per_page])

    authorize @lounges
    render json: {
      lounges: ActiveModelSerializers::SerializableResource.new(
        @lounges,
        each_serializer: Api::V1::LoungesSerializer
      ),
      pagination: pagination_metadata(@lounges)
    }
  end

  # GET /lounges/1
  def show
    authorize @lounge
    render json: @lounge, serializer: Api::V1::LoungesSerializer
  end

  # POST /lounges
  def create
    @lounge = Lounge.new(lounge_params)
    authorize @lounge
    if @lounge.save
      render json: @lounge, status: :created, serializer: Api::V1::LoungesSerializer
    else
      render json: @lounge.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lounges/1
  def update
    if @lounge.update(lounge_params)
      render json: @lounge, serializer: Api::V1::LoungesSerializer
    else
      render json: @lounge.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lounges/1
  def destroy
    authorize @lounge
    @lounge.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lounge
      @lounge = Lounge.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lounge_params
      params.require(:lounge).permit(:name, :description, :lounge_design_id)
    end

    def filter_params
      params.permit(:lounge_design_id, :date_from, :date_to, :search)
    end
end
