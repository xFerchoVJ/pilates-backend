class Api::V1::UsersController < ApplicationController
  include Filterable

  before_action :set_user, only: [ :show, :update, :destroy ]
  before_action :authenticate_user!, except: [ :send_password_reset, :reset_password, :validate_password_reset_token ]

  # GET /api/v1/users
  def index
    @users = User.all.order(:created_at)

    # Apply filters
    @users = apply_filters(@users, filter_params)

    # Apply pagination
    @users = paginate_collection(@users, page: params[:page], per_page: params[:per_page])

    authorize @users
    render json: {
      users: ActiveModelSerializers::SerializableResource.new(
        @users,
        each_serializer: Api::V1::UsersSerializer
      ),
      pagination: pagination_metadata(@users)
    }
  end

  # GET /api/v1/users/:id
  def show
    authorize @user
    render json: @user, serializer: Api::V1::UsersSerializer
  end

  # POST /api/v1/users
  def create
    @user = User.new(user_params)
    authorize @user
    if @user.save
      render json: @user, serializer: Api::V1::UsersSerializer, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/users/:id
  def update
    # Solo permitir que los usuarios actualicen su propio perfil o que los admins actualicen cualquier perfil
    authorize @user

    if @user.update(user_params)
      render json: @user, serializer: Api::V1::UsersSerializer
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/users/:id
  def destroy
    authorize @user
    if @user.destroy
      render json: {
        success: true,
        message: "Usuario eliminado exitosamente"
      }
    else
      render json: {
        success: false,
        message: "Error al eliminar el usuario",
        errors: @user.errors, status: :unprocessable_entity
      }, status: :unprocessable_entity
    end
  end

  def send_password_reset
    @user = User.find_by(email: params[:email])
    if @user
      @user.generate_password_reset_token!
      UserMailer.password_reset(@user).deliver_later
    end

    render json: {
      success: true,
      message: "Si el correo existe en nuestro sistema, se enviará un enlace de recuperación"
    }
  end

  def reset_password
    @user = User.find_by(reset_password_token: params[:reset_password_token])

    if @user.nil?
      return render json: {
        success: false,
        message: "Token de restablecimiento de contraseña inválido"
      }, status: :unauthorized
    end

    unless @user.reset_token_valid?
      return render json: {
        success: false,
        message: "El token ha expirado"
      }, status: :unauthorized
    end

    if params[:password].blank?
      return render json: {
        success: false,
        message: "La nueva contraseña no puede estar vacía"
      }, status: :unprocessable_entity
    end

    if @user.update(password: params[:password])
      @user.clear_reset_token!
      render json: {
        success: true,
        message: "Contraseña restablecida exitosamente"
      }
    else
      render json: {
        success: false,
        message: "Error al restablecer la contraseña",
        errors: @user.errors, status: :unprocessable_entity
      }, status: :unprocessable_entity
    end
  end

  def validate_password_reset_token
    return render json: { message: "Token de restablecimiento de contraseña inválido" }, status: :unauthorized if params[:reset_password_token].blank?

    @user = User.find_by(reset_password_token: params[:reset_password_token])
    return render json: { message: "Token de restablecimiento de contraseña inválido" }, status: :unauthorized if @user.nil?
    return render json: { message: "Token de restablecimiento de contraseña expirado" }, status: :unauthorized unless @user.reset_token_valid?

    render json: { message: "Token de restablecimiento de contraseña válido" }, status: :ok
  end


  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      message: "Usuario no encontrado"
    }, status: :not_found
  end

  def filter_params
    params.permit(:search, :role, :gender, :date_from, :date_to)
  end

  def user_params
    # Filtrar parámetros según el rol del usuario actual
    permitted_params = [ :name, :last_name, :email, :phone, :gender, :birthdate, :profile_picture ]

    # Solo permitir cambiar password si no es un usuario de Google
    if params[:user] && params[:user][:password].present? && @user&.provider.blank?
      permitted_params += [ :password, :password_confirmation ]
    end

    # Solo los admins pueden cambiar el rol
    if @current_user&.admin?
      permitted_params << :role
    end

    # Handle both nested (:user) and direct parameter formats
    if params[:user]
      params.require(:user).permit(permitted_params)
    else
      params.permit(permitted_params)
    end
  end
end
