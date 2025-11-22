class Api::V1::ReservationsController < ApplicationController
  include Filterable
  before_action :authenticate_user!
  before_action :set_reservation, only: %i[ show update destroy ]

  # GET /reservations
  def index
    @reservations = Reservation.includes(:user, :class_session).order(:created_at)

    # Apply filters via service
    @reservations = ::Filters::ReservationsFilter.call(@reservations, filter_params)

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

  # POST /reservations/create_with_payment
  def create_with_payment
    authorize Reservation, :create_with_payment?
    service = Reservations::CreateWithPaymentService.new(
      class_session_id: params[:class_session_id],
      user: @current_user,
      class_space_id: params[:class_space_id],
      coupon_code: params[:coupon_code] || nil
    )
    result = service.call
    if result[:success]
      render json: { client_secret: result[:client_secret] }, status: :ok
    else
      render json: { error: result[:message] }, status: :unprocessable_entity
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def filter_params
      params.permit(:user_id, :class_session_id, :class_space_id, :date_from, :date_to, :active)
    end

    # Only allow a list of trusted parameters through.
    def reservation_params
      params.require(:reservation).permit(:user_id, :class_session_id, :class_space_id, :status)
    end
end
