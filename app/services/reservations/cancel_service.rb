class Reservations::CancelService
  def initialize(reservation:)
    @reservation = reservation
    @user = reservation.user
  end

  def call
    Rails.logger.info("Cancelando reserva: #{@reservation.id}")
    Reservation.transaction do
      handle_refund_logic
      Rails.logger.info("Reembolsando reserva: #{@reservation.id}")
      @reservation.destroy!
      Rails.logger.info("Reserva cancelada: #{@reservation.id}")
    end
  end

  private

  # -----------------------------------------
  # Lógica de reembolsos según método de pago
  # -----------------------------------------
  def handle_refund_logic
    tx = find_transaction
    return if tx.blank?            # No debería pasar pero por si acaso

    # Si falta más de 6 horas para la clase
    return unless refundable?      # <- si ya no es elegible, no se devuelve nada

    case tx.transaction_type
    when "class_redeemed"
      refund_package(tx)
    when "class_payment"
      refund_payment(tx)
    when "class_credit_used"
      refund_credit(tx)
    end
  end

  # -----------------------------------------
  # Buscar la transacción asociada a la reserva
  # -----------------------------------------
  def find_transaction
    # Para class_payment: la transacción referencia directamente a la reserva
    tx = Transaction.find_by(reference: @reservation, reference_type: "Reservation")
    return tx if tx.present?

    # Para class_credit_used: la transacción referencia al crédito usado
    credit = ClassCredit.find_by(reservation: @reservation, status: "used")
    if credit
      tx = Transaction.find_by(
        reference: credit,
        reference_type: "ClassCredit",
        transaction_type: "class_credit_used"
      )
      return tx if tx.present?
    end

    # Para class_redeemed: necesitamos encontrar qué paquete se usó
    # Buscamos la transacción más reciente de tipo class_redeemed del usuario
    # que se haya creado antes o al mismo tiempo que la reserva
    tx = Transaction.where(
      user: @user,
      transaction_type: "class_redeemed",
      reference_type: "UserClassPackage"
    ).where("created_at <= ?", @reservation.created_at + 1.minute)
     .order(created_at: :desc)
     .first

    # Verificar que la transacción referencie un paquete válido del usuario
    if tx && tx.reference.is_a?(UserClassPackage) && tx.reference.user == @user
      return tx
    end

    nil
  end

  # -----------------------------------------
  # REGRESAR 1 CLASE AL PAQUETE
  # -----------------------------------------
  def refund_package(tx)
    package = tx.reference if tx.reference.is_a?(UserClassPackage)
    return if package.nil?

    # Solo incrementar si no es ilimitado
    unless package.class_package.unlimited?
      package.increment!(:remaining_classes)
      # Si estaba completado, reactivarlo
      package.update!(status: "active") if package.status == "completed"
    end
  end

  # -----------------------------------------
  # CREAR NUEVO CRÉDITO POR PAGO
  # -----------------------------------------
  def refund_payment(tx)
    # Crear crédito de clase asociado a la reserva
    # Con dependent: :nullify, el crédito se preservará cuando se destruya la reserva
    ClassCredit.create!(
      user: @user,
      reservation: @reservation,
      status: "unused"
    )
  end

  # -----------------------------------------
  # RESTAURAR EL CRÉDITO USADO
  # -----------------------------------------
  def refund_credit(tx)
    credit = tx.reference if tx.reference.is_a?(ClassCredit)
    credit ||= ClassCredit.find_by(reservation: @reservation, status: "used")
    return if credit.nil?

    # Actualizar el crédito y desasociarlo de la reserva
    # para que no se destruya cuando se destruya la reserva
    credit.update!(
      status: "unused",
      used_at: nil,
      reservation: nil
    )
  end

  # -----------------------------------------
  # Regla de > 6 horas para aplicar reembolsos
  # La reserva siempre se puede cancelar, pero los reembolsos
  # solo se aplican si faltan más de 6 horas para la clase
  # -----------------------------------------
  def refundable?
    class_time = @reservation.class_session.start_time
    Time.current < (class_time - 6.hours)
  end
end
