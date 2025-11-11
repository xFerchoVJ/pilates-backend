class Api::V1::DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: %i[ show update destroy ]
  # GET /devices
  def index
    @devices = @current_user.devices

    authorize @devices
    render json: @devices, each_serializer: Api::V1::DeviceSerializer
  end

  # GET /devices/1
  def show
    authorize @device
    render json: @device, serializer: Api::V1::DeviceSerializer
  end

  # POST /devices
  def create
    @device = Device.new(device_params)

    authorize @device
    if @device.save
      render json: @device, status: :created, serializer: Api::V1::DeviceSerializer
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /devices/1
  def update
    authorize @device
    if @device.update(device_params)
      render json: @device, serializer: Api::V1::DeviceSerializer
    else
      render json: @device.errors, status: :unprocessable_entity
    end
  end

  # DELETE /devices/1
  def destroy
    authorize @device
    @device.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def device_params
      params.require(:device).permit(:user_id, :expo_push_token)
    end
end
