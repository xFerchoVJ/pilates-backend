class Api::V1::ClassCreditsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_class_credit, only: %i[ show ]
  include Filterable

  def index
    @class_credits = ClassCredit.all
    # Apply filters via service
    @class_credits = ::Filters::ClassCreditsFilter.call(@class_credits, filter_params)

    # Apply pagination
    @class_credits = paginate_collection(@class_credits, page: params[:page], per_page: params[:per_page])

    authorize @class_credits
    render json: {
      class_credits: ActiveModelSerializers::SerializableResource.new(
        @class_credits,
        each_serializer: Api::V1::ClassCreditSerializer
      ),
      pagination: pagination_metadata(@class_credits)
    }
  end

  def create
    @class_credit = ClassCredit.new(class_credit_params)
    authorize @class_credit
    if @class_credit.save
      render json: @class_credit, serializer: Api::V1::ClassCreditSerializer
    else
      render json: { errors: @class_credit.errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @class_credit
    render json: @class_credit, serializer: Api::V1::ClassCreditSerializer
  end
end

private

def class_credit_params
  params.require(:class_credit).permit(:user_id, :reservation_id, :status, :used_at)
end

def filter_params
  params.permit(:user_id, :reservation_id, :status, :used_from, :used_to)
end

def set_class_credit
  @class_credit = ClassCredit.find(params[:id])
end
