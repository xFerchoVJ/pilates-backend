class User < ApplicationRecord
  has_secure_password validations: false

  enum role: { user: 0, instructor: 1, admin: 2 }

  validates :email, presence: { message: "El email es requerido" }, uniqueness: true
  validate :password_presence_if_local

  private
  def password_presence_if_local
    # Si no es Google, requiere password
    if provider.blank? && (password_digest.blank? && password.blank?)
      errors.add(:password, "no puede estar vacío")
    end
  end
end
