class UserMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"]

  def password_reset(user)
    @user = user
    @token = user.reset_password_token
    mail(to: @user.email, subject: "Restablecer contraseña")
  end
end
