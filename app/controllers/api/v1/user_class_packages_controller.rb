class Api::V1::UserClassPackagesController < ApplicationController
  include Filterable
  before_action :set_user_class_package, only: %i[ show ]
  before_action :authenticate_user!

  # GET /api/v1/user_class_packages
  def index
    if @current_user.admin?
      @user_class_packages = UserClassPackage.includes(:user, :class_package).order(:created_at)
    else
      @user_class_packages = @current_user.user_class_packages.includes(:class_package).order(:created_at)
    end

    # Apply filters via service
    @user_class_packages = ::Filters::UserClassPackagesFilter.call(@user_class_packages, filter_params)

    # Apply pagination
    @user_class_packages = paginate_collection(@user_class_packages, page: params[:page], per_page: params[:per_page])

    authorize @user_class_packages
    render json: {
      user_class_packages: ActiveModelSerializers::SerializableResource.new(
        @user_class_packages,
        each_serializer: Api::V1::UserClassPackageSerializer
      ),
      pagination: pagination_metadata(@user_class_packages)
    }
  end

  # GET /api/v1/user_class_packages/1
  def show
    render json: @user_class_package, serializer: Api::V1::UserClassPackageSerializer
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_class_package
      @user_class_package = UserClassPackage.find(params[:id])
    end

    def filter_params
      params.permit(:user_id, :class_package_id, :status, :remaining_classes_min, :remaining_classes_max, :purchased_from, :purchased_to, :date_from, :date_to)
    end
end
