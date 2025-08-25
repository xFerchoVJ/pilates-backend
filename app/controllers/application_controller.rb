class ApplicationController < ActionController::API
  before_action :set_current_user

  private

  def set_current_user
    header = request.headers["Authorization"]
    token  = header&.split("Bearer ")&.last
    return unless token

    decoded = JwtService.decode(token)
    return unless decoded

    @current_user = User.find_by(id: decoded["sub"])
  end

  def authenticate_user!
    render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
  end

  def require_role!(*roles)
    authenticate_user!
    return if performed?
    render json: { error: "forbidden" }, status: :forbidden unless roles.map(&:to_s).include?(@current_user.role)
  end
end
