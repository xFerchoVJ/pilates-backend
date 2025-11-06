class ClassPackages::PurchaseWithPaymentService
  def initialize(class_package_id:, user:)
    @class_package_id = class_package_id
    @user = user
  end

  def call
    return failure("El paquete de clase es requerido") if @class_package_id.blank?
    return failure("El usuario es requerido") if @user.blank?

    @class_package = ClassPackage.find_by(id: @class_package_id)
    failure("El paquete de clase no fue encontrado") unless @class_package
    service = Payments::PaymentIntentService.new(
      user: @user,
      amount: @class_package.price,
      currency: "mxn",
      transaction_type: "package_purchase",
      reference: @class_package,
      reference_type: "ClassPackage",
      metadata: {
        user_id: @user.id,
        class_package_id: @class_package.id
      }
    )
    result = service.call
    if result[:success]
      success(client_secret: result[:client_secret])
    else
      failure(result[:message])
    end
  end

  private
  def success(data)
    { success: true }.merge(data)
  end

  def failure(message)
    { success: false, message: message }
  end
end
