class Api::V1::ReservationsController < ApplicationController
  include Filterable

  before_action :set_reservation, only: %i[ show update destroy ]

  # GET /reservations
  def index
    @reservations = Reservation.includes(:user, :class_session).order(:created_at)

    # Apply filters
    @reservations = apply_filters(@reservations, filter_params)

    # Apply pagination
    @reservations = paginate_collection(@reservations, page: params[:page], per_page: params[:per_page])

    authorize @reservations
    render json: {
      reservations: ActiveModelSerializers::SerializableResource.new(
        @reservations,
        each_serializer: Api::V1::ReservationSerializer
      ),
      pagination: pagination_metadata(@reservations)
    }
  end

  # GET /reservations/1
  def show
    authorize @reservation
    render json: @reservation, serializer: Api::V1::ReservationSerializer
  end

  # POST /reservations
  def create
    @reservation = Reservation.new(reservation_params)
    authorize @reservation
    if @reservation.save
      render json: @reservation, status: :created, serializer: Api::V1::ReservationSerializer
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reservations/1
  def update
    authorize @reservation
    if @reservation.update(reservation_params)
      render json: @reservation, serializer: Api::V1::ReservationSerializer, status: :ok
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reservations/1
  def destroy
    authorize @reservation
    @reservation.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def filter_params
      params.permit(:user_id, :class_session_id, :date_from, :date_to)
    end

    # Only allow a list of trusted parameters through.
    def reservation_params
      params.require(:reservation).permit(:user_id, :class_session_id)
    end
end
