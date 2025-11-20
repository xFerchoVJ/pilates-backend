class Api::V1::ClassPackagesController < ApplicationController
  include Filterable
  before_action :set_class_package, only: %i[ show update destroy ]
  before_action :authenticate_user!
  # GET /api/v1/class_packages
  def index
    @class_packages = ClassPackage.all

    # Apply filters via service
    @class_packages = ::Filters::ClassPackagesFilter.call(@class_packages, filter_params)

    # Apply pagination
    @class_packages = paginate_collection(@class_packages, page: params[:page], per_page: params[:per_page])

    authorize @class_packages
    render json: {
      class_packages: ActiveModelSerializers::SerializableResource.new(
        @class_packages,
        each_serializer: Api::V1::ClassPackageSerializer
      ),
      pagination: pagination_metadata(@class_packages)
    }
  end

  # GET /api/v1/class_packages/1
  def show
    authorize @class_package
    render json: @class_package, serializer: Api::V1::ClassPackageSerializer
  end

  # POST /api/v1/class_packages
  def create
    @class_package = ClassPackage.new(class_package_params)

    authorize @class_package
    if @class_package.save
      render json: @class_package, serializer: Api::V1::ClassPackageSerializer, status: :created
    else
      render json: @class_package.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/class_packages/1
  def update
    authorize @class_package
    if @class_package.update(class_package_params)
      render json: @class_package, serializer: Api::V1::ClassPackageSerializer, status: :ok
    else
      render json: @class_package.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/class_packages/1
  def destroy
    authorize @class_package
    @class_package.destroy!
  end


  # POST /api/v1/class_packages/purchase_with_payment
  def purchase_with_payment
    authorize ClassPackage, :purchase_with_payment?
    service = ClassPackages::PurchaseWithPaymentService.new(
      class_package_id: params[:class_package_id],
      user: @current_user
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
    def set_class_package
      @class_package = ClassPackage.find(params[:id])
    end

    def filter_params
      params.permit(:search, :status, :currency, :price_min, :price_max, :class_count_min, :class_count_max, :date_from, :date_to, :unlimited, :limited)
    end

    # Only allow a list of trusted parameters through.
    def class_package_params
      params.require(:class_package).permit(:name, :description, :class_count, :price, :currency, :status, :unlimited, :expires_in_days, :daily_limit)
    end
end
