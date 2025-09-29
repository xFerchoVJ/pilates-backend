class UserMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"]

  def password_reset(user)
    @user = user
    @token = user.reset_password_token
    @frontend_reset_url = "#{ENV.fetch('FRONTEND_URL', 'https://luumstudio.com')}/reset-password?token=#{@token}"
    mail(to: @user.email, subject: "Restablecer contraseña")
  end
end
