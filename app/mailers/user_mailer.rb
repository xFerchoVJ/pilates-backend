class UserMailer < ApplicationMailer
  default from: ENV["GMAIL_USERNAME"]

  def password_reset(user)
    @user = user
    @token = user.reset_password_token
    mail(to: @user.email, subject: "Restablecer contraseña")
  end

  def reservation_confirmation(reservation)
    @user = reservation.user
    @reservation = reservation
    @class_session = reservation.class_session
    @class_space = reservation.class_space
    mail(to: @user.email, subject: "Confirmación de reserva - #{@class_session.name}")
  end
end
