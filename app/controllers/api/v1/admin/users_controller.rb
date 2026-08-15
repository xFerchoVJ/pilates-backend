class Api::V1::Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_user, only: [ :password ]

  def birthdays
    month = birthday_month
    return render json: { error: "El mes debe ser un numero entre 1 y 12" }, status: :unprocessable_entity if month.nil?

    users = User.where(role: [ :user, :instructor ])
                .where.not(birthdate: nil)
                .where("EXTRACT(MONTH FROM birthdate) = ?", month)
                .order(Arel.sql("EXTRACT(DAY FROM birthdate) ASC"), :name, :last_name)

    render json: {
      month: month,
      birthdays: users.map { |user| birthday_payload(user) }
    }
  end

  def password
    return render json: { error: "No puedes cambiar tu propia contrasena desde este endpoint" }, status: :forbidden if @user.id == @current_user.id
    return render json: { error: "No puedes cambiar la contrasena de otro administrador" }, status: :forbidden if @user.admin?

    new_password = password_param.to_s
    return render json: { error: "La nueva contrasena no puede estar vacia" }, status: :unprocessable_entity if new_password.blank?

    if @user.update(password: new_password)
      render json: { success: true, message: "Contrasena actualizada exitosamente" }
    else
      render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ensure_admin!
    return if performed?
    return if @current_user&.admin?

    render json: { error: "No tienes permisos para esta accion" }, status: :forbidden
  end

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Usuario no encontrado" }, status: :not_found
  end

  def birthday_month
    return Time.zone.today.month if params[:month].blank?

    month = Integer(params[:month], exception: false)
    return month if month&.between?(1, 12)
  end

  def birthday_payload(user)
    {
      id: user.id,
      name: user.name,
      last_name: user.last_name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      birthdate: user.birthdate
    }
  end

  def password_param
    if params[:user].present?
      params.require(:user).permit(:password)[:password]
    else
      params[:password]
    end
  end
end
