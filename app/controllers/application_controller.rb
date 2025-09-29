class ApplicationController < ActionController::API
  before_action :set_current_user
  include Pundit::Authorization

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

  # Método requerido por Pundit
  def current_user
    @current_user
  end
end
