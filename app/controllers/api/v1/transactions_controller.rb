class Api::V1::TransactionsController < ApplicationController
  include Filterable
  before_action :set_transaction, only: [ :show ]

  def index
    @transactions = Transaction.includes(:user, :reference).order(:created_at)

    # Apply filters via service
    @transactions = ::Filters::TransactionsFilter.call(@transactions, filter_params)

    # Apply pagination
    @transactions = paginate_collection(@transactions, page: params[:page], per_page: params[:per_page])

    authorize @transactions
    render json: {
      transactions: ActiveModelSerializers::SerializableResource.new(
        @transactions,
        each_serializer: Api::V1::TransactionSerializer
      ),
      pagination: pagination_metadata(@transactions)
    }
  end

  def show
    authorize @transaction
    render json: @transaction, serializer: Api::V1::TransactionSerializer
  end
end

private

def filter_params
  params.permit(:user_id, :status, :transaction_type)
end

def set_transaction
  @transaction = Transaction.find(params[:id])
end
