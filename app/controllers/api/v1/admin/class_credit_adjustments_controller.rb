class Api::V1::Admin::ClassCreditAdjustmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_user

  def create
    amount = Integer(adjustment_params[:amount], exception: false)
    reason = adjustment_params[:reason].to_s.strip
    expires_at = parsed_expires_at

    return render json: { error: "La cantidad debe ser un número entero" }, status: :unprocessable_entity if amount.nil?
    return render json: { error: "La cantidad no puede ser 0" }, status: :unprocessable_entity if amount.zero?
    return render json: { error: "El motivo es requerido" }, status: :unprocessable_entity if reason.blank?
    return render json: { error: "La fecha de expiración no es válida" }, status: :unprocessable_entity if expires_at == :invalid

    result = apply_adjustment!(amount: amount, reason: reason, expires_at: expires_at)
    render json: result, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end

  private

  def ensure_admin!
    return if performed?
    return if @current_user&.admin?

    render json: { error: "No tienes permisos para esta acción" }, status: :forbidden
  end

  def set_user
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Usuario no encontrado" }, status: :not_found
  end

  def adjustment_params
    params.permit(:amount, :reason, :expires_at, metadata: {})
  end

  def apply_adjustment!(amount:, reason:, expires_at:)
    credit_ids = []
    payload = nil

    ActiveRecord::Base.transaction do
      @user.with_lock do
        credit_ids = amount.positive? ? add_credits(amount, expires_at) : void_credits(amount.abs)

        adjustment = ClassCreditAdjustment.create!(
          user: @user,
          admin_user: @current_user,
          amount: amount,
          reason: reason,
          credit_ids: credit_ids,
          metadata: adjustment_metadata.merge(expires_at: expires_at&.iso8601)
        )

        payload = response_payload(adjustment)
      end
    end

    payload
  end

  def add_credits(amount, expires_at)
    amount.times.map do
      ClassCredit.create!(user: @user, status: "unused", expires_at: expires_at).id
    end
  end

  def void_credits(amount)
    credits = @user.class_credits
                   .unused
                   .not_expired
                   .order(Arel.sql("expires_at ASC NULLS LAST"), :created_at)
                   .limit(amount)
                   .to_a

    if credits.size < amount
      raise ActiveRecord::RecordInvalid.new(ClassCredit.new.tap do |credit|
        credit.errors.add(:base, "El usuario no tiene suficientes créditos disponibles")
      end)
    end

    credits.each { |credit| credit.update!(status: "voided") }
    credits.map(&:id)
  end

  def adjustment_metadata
    adjustment_params[:metadata]&.to_h || {}
  end

  def parsed_expires_at
    return nil if adjustment_params[:expires_at].blank?

    Time.zone.parse(adjustment_params[:expires_at].to_s) || :invalid
  rescue ArgumentError, TypeError
    :invalid
  end

  def response_payload(adjustment)
    {
      success: true,
      user_id: @user.id,
      available_credits: @user.class_credits.unused.not_expired.count,
      adjustment: {
        id: adjustment.id,
        amount: adjustment.amount,
        reason: adjustment.reason,
        credit_ids: adjustment.credit_ids,
        expires_at: adjustment.metadata["expires_at"],
        created_at: adjustment.created_at
      }
    }
  end
end
