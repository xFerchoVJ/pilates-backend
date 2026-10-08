class ApplicationController < ActionController::API
  before_action :set_current_user
  include Pundit::Authorization

  IDEMPOTENCY_KEY_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_current_user
    header = request.headers["Authorization"]
    token  = header&.split("Bearer ")&.last
    return unless token

    decoded = JwtService.decode(token)
    return unless decoded

    # Verificar si el token está en la blacklist
    return if BlacklistedToken.blacklisted?(decoded["jti"])

    @current_user = User.find_by(id: decoded["sub"])
  end

  def authenticate_user!
    render json: { error: "Debes de iniciar sesión" }, status: :unauthorized unless @current_user
  end

  def require_role!(*roles)
    authenticate_user!
    return if performed?
    render json: { error: "forbidden" }, status: :forbidden unless roles.map(&:to_s).include?(@current_user.role)
  end

  def user_not_authorized
    render json: { error: "No tienes permisos para esta acción" }, status: :forbidden
  end

  def execute_idempotent(endpoint:, payload:)
    key = request.headers["Idempotency-Key"].to_s.strip
    if key.blank?
      return render_api_error(code: "IDEMPOTENCY_KEY_REQUIRED", message: "El encabezado Idempotency-Key es requerido", status: :bad_request)
    end

    unless key.length <= 255 && key.match?(IDEMPOTENCY_KEY_PATTERN)
      return render_api_error(code: "IDEMPOTENCY_KEY_INVALID", message: "Idempotency-Key debe ser un UUID válido", status: :bad_request)
    end

    result = Idempotency::ExecuteRequestService.new(
      user: @current_user,
      endpoint: endpoint,
      key: key,
      payload: payload
    ).call { |idempotency_request| yield(idempotency_request) }

    response.set_header("Idempotency-Replayed", result[:replayed].to_s)
    render json: result[:body], status: result[:status]
  rescue Idempotency::ExecuteRequestService::ConflictError => e
    render_api_error(code: "IDEMPOTENCY_CONFLICT", message: e.message, status: :conflict)
  end

  def render_api_error(code:, message:, status:, field_errors: {})
    render json: {
      code: code,
      message: message,
      field_errors: field_errors,
      request_id: request.request_id
    }, status: status
  end

  # Método requerido por Pundit
  def current_user
    @current_user
  end
end
