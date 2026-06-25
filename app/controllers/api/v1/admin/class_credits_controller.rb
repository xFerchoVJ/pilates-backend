class Api::V1::Admin::ClassCreditsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_class_credit

  def void
    reason = params[:reason].to_s.strip
    return render json: { error: "El motivo es requerido" }, status: :unprocessable_entity if reason.blank?
    return render json: { error: "El crédito no está disponible para anularse" }, status: :unprocessable_entity unless @class_credit.unused?

    adjustment = nil

    ActiveRecord::Base.transaction do
      @class_credit.with_lock do
        raise ActiveRecord::RecordInvalid, @class_credit unless @class_credit.unused?

        @class_credit.update!(status: "voided")
        adjustment = ClassCreditAdjustment.create!(
          user: @class_credit.user,
          admin_user: @current_user,
          amount: -1,
          reason: reason,
          credit_ids: [ @class_credit.id ],
          metadata: adjustment_metadata
        )
      end
    end

    render json: response_payload(adjustment), status: :ok
  rescue ActiveRecord::RecordInvalid
    render json: { error: "El crédito no está disponible para anularse" }, status: :unprocessable_entity
  end

  private

  def ensure_admin!
    return if performed?
    return if @current_user&.admin?

    render json: { error: "No tienes permisos para esta acción" }, status: :forbidden
  end

  def set_class_credit
    @class_credit = ClassCredit.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Crédito no encontrado" }, status: :not_found
  end

  def adjustment_metadata
    metadata = params[:metadata]
    metadata.respond_to?(:to_unsafe_h) ? metadata.to_unsafe_h : {}
  end

  def response_payload(adjustment)
    user = @class_credit.user

    {
      success: true,
      user_id: user.id,
      credit_id: @class_credit.id,
      available_credits: user.class_credits.unused.not_expired.count,
      adjustment: {
        id: adjustment.id,
        amount: adjustment.amount,
        reason: adjustment.reason,
        credit_ids: adjustment.credit_ids,
        created_at: adjustment.created_at
      }
    }
  end
end
