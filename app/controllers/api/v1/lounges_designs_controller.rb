class Api::V1::LoungesDesignsController < ApplicationController
  before_action :set_lounges_design, only: %i[ show update destroy ]
  before_action :authenticate_user!

  # GET /api/v1/lounges_designs
  def index
    @lounges_designs = LoungeDesign.all

    authorize @lounges_designs
    render json: @lounges_designs, each_serializer: Api::V1::LoungeDesignSerializer
  end

  # GET /api/v1/lounges_designs/1
  def show
    authorize @lounges_design
    render json: @lounges_design, serializer: Api::V1::LoungeDesignSerializer
  end

  # POST /api/v1/lounges_designs
  def create
    @lounges_design = LoungeDesign.new(lounges_design_params)

    authorize @lounges_design
    if @lounges_design.save
      render json: @lounges_design, status: :created, serializer: Api::V1::LoungeDesignSerializer
    else
      render json: @lounges_design.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/lounges_designs/1
  def update
    authorize @lounges_design
    if @lounges_design.update(lounges_design_params)
      render json: @lounges_design, serializer: Api::V1::LoungeDesignSerializer
    else
      render json: @lounges_design.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/lounges_designs/1
  def destroy
    authorize @lounges_design
    @lounges_design.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lounges_design
      @lounges_design = LoungeDesign.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lounges_design_params
      params.require(:lounge_design).permit(:name, :description, layout_json: { spaces: [ :label, :x, :y ] })
    end
end
