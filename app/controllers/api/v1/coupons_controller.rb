class Api::V1::CouponsController < ApplicationController
  before_action :set_coupon, only: %i[ show update destroy ]
  include Filterable
  # GET /coupons
  def index
    @coupons = Coupon.all

    # Apply filters via service
    @coupons = ::Filters::CouponsFilter.call(@coupons, filter_params)

    # Apply pagination
    @coupons = paginate_collection(@coupons, page: params[:page], per_page: params[:per_page])

    authorize @coupons
    render json: {
      coupons: ActiveModelSerializers::SerializableResource.new(
        @coupons,
        each_serializer: Api::V1::CouponsSerializer
      ),
      pagination: pagination_metadata(@coupons)
    }
  end

  # GET /coupons/1
  def show
    authorize @coupon
    render json: @coupon, serializer: Api::V1::CouponsSerializer
  end

  # POST /coupons
  def create
    @coupon = Coupon.new(coupon_params)
    @coupon.code = @coupon.code.upcase

    authorize @coupon
    if @coupon.save
      render json: @coupon, serializer: Api::V1::CouponsSerializer, status: :created
    else
      render json: @coupon.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /coupons/1
  def update
    authorize @coupon
    if @coupon.update(coupon_params)
      render json: @coupon, serializer: Api::V1::CouponsSerializer
    else
      render json: @coupon.errors, status: :unprocessable_entity
    end
  end

  # DELETE /coupons/1
  def destroy
    authorize @coupon
    @coupon.destroy!
  end

  # POST /coupons/validate
  def validate
    service = Coupons::ValidateAndApplyService.new(
      coupon_code: params[:coupon_code],
      price_cents: params[:price_cents] || 0,
      user: current_user,
      context: { class_session_id: params[:class_session_id] || nil }
    )

    result = service.call

    if result[:success]
      render json: {
        success: true,
        discount_cents: result[:discount_cents],
        final_amount_cents: result[:final_amount_cents],
        coupon: (result[:coupon]&.as_json(only: [ :id, :code, :discount_type, :discount_value ]))
      }, status: :ok
    else
      render json: { success: false, message: result[:message] }, status: :unprocessable_entity
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coupon
      @coupon = Coupon.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def coupon_params
      params.require(:coupon).permit(:code, :discount_type, :discount_value, :usage_limit, :usage_limit_per_user, :only_new_users, :active, :starts_at, :ends_at, :metadata, :times_used)
    end

    def filter_params
      params.permit(:search, :only_new_users, :active_now)
    end
end
