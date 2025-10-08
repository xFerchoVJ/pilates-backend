class Api::V1::AuthController < ApplicationController
  # No exige token para estas
  skip_before_action :set_current_user, only: %i[signup login google]
  # signup (local), login (local), login con google (id_token), refresh, logout

  def signup
    user = User.new(user_params.merge(provider: nil))
    if user.save
      render json: token_bundle_for(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user&.authenticate(params[:password].to_s)
      render json: token_bundle_for(user)
    else
      render json: { error: "email o contraseña inválidos" }, status: :unauthorized
    end
  end

  def google
    payload = GoogleIdTokenService.verify(params[:id_token].to_s)
    return render json: { error: "token inválido" }, status: :unauthorized unless payload

    email   = payload[:email].to_s.downcase
    uid     = payload[:sub]
    name    = payload[:given_name]
    last    = payload[:family_name]
    verified= payload[:email_verified].to_s == "true" || payload[:email_verified] == true

    user = User.find_or_initialize_by(email: email)
    user.assign_attributes(
      provider: "google",
      uid: uid,
      name: user.name.presence || name,
      last_name: user.last_name.presence || last,
      google_email_verified: verified
    )
    # usuarios Google no requieren password
    user.role ||= :user

    if user.save(validate: false) # ya validamos email; omitimos password
      render json: token_bundle_for(user)
    else
      render json: { error: "no se pudo crear el usuario Google" }, status: :unprocessable_entity
    end
  end

  def refresh
    token = RefreshTokenUser.active.find_by(jti: params[:refresh_token].to_s)
    return render json: { error: "refresh inválido" }, status: :unauthorized unless token

    user = token.user
    # rotación de refresh: invalidar el viejo y emitir uno nuevo
    token.update!(revoked_at: Time.current)
    render json: token_bundle_for(user)
  end

  def logout
    # Blacklist el access_token actual si existe
    if @current_user
      header = request.headers["Authorization"]
      token = header&.split("Bearer ")&.last
      if token
        decoded = JwtService.decode(token)
        if decoded && decoded["jti"]
          BlacklistedToken.blacklist!(decoded["jti"], Time.at(decoded["exp"]))
        end
      end
    end

    # Invalidar refresh_token si se proporciona
    if params[:refresh_token].present?
      RefreshTokenUser.find_by(jti: params[:refresh_token])&.update!(revoked_at: Time.current)
    end

    render json: { message: "Logout exitoso" }
  end

  def logout_all
    return render json: { error: "No autorizado" }, status: :unauthorized unless @current_user

    # Invalidar todos los refresh tokens del usuario
    RefreshTokenUser.where(user: @current_user).update_all(revoked_at: Time.current)

    # Blacklist el access_token actual
    header = request.headers["Authorization"]
    token = header&.split("Bearer ")&.last
    if token
      decoded = JwtService.decode(token)
      if decoded && decoded["jti"]
        BlacklistedToken.blacklist!(decoded["jti"], Time.at(decoded["exp"]))
      end
    end

    render json: { message: "Logout de todos los dispositivos exitoso" }
  end

  def cleanup_tokens
    return render json: { error: "No autorizado" }, status: :unauthorized unless @current_user
    return render json: { error: "Solo administradores" }, status: :forbidden unless @current_user.admin?

    # Programar job de limpieza
    CleanupExpiredTokensJob.perform_async

    render json: { message: "Limpieza de tokens programada" }
  end

  private

  def token_bundle_for(user)
    access_payload = { sub: user.id, role: user.role }
    access_token = JwtService.encode(access_payload, exp: JwtService.access_exp.from_now)

    refresh_jti = SecureRandom.uuid
    RefreshTokenUser.create!(
      user: user,
      jti: refresh_jti,
      user_agent: request.user_agent,
      ip: request.remote_ip,
      expires_at: JwtService.refresh_exp.from_now
    )

    {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        last_name: user.last_name,
        phone: user.phone,
        role: user.role,
        gender: user.gender,
        birthdate: user.birthdate,
        profile_picture_url: user.profile_picture.attached? ? user.profile_picture.url : nil,
        injuries: user.injuries
      },
      access_token: access_token,
      expires_in: JwtService.access_exp.to_i,
      refresh_token: refresh_jti
    }
  end

  def user_params
    params.require(:user).permit(:email, :password, :name, :last_name, :phone, :role, :gender, :birthdate)
          .tap { |p| p[:email] = p[:email].to_s.downcase if p[:email] }
  end
end
