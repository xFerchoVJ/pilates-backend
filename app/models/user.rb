class User < ApplicationRecord
  has_secure_password validations: false

  has_one_attached :profile_picture

  enum role: { user: 0, instructor: 1, admin: 2 }

  enum gender: { male: "hombre", female: "mujer", other: "otro" }

  validates :email, presence: { message: "El email es requerido" }, uniqueness: true
  validate :password_presence_if_local
  validates :birthdate, presence: { message: "La fecha de nacimiento es requerida" }
  validates :gender, presence: { message: "El género es requerido" }
  validates :name, presence: { message: "El nombre es requerido" }
  validates :last_name, presence: { message: "El apellido es requerido" }
  validates :phone, presence: { message: "El teléfono es requerido" }
  validates :role, presence: { message: "El rol es requerido" }

  # Campos que se incluyen en la respuesta del token
  PUBLIC_ATTRIBUTES = %w[id email name last_name phone role gender birthdate].freeze

  def public_attributes
    data = attributes.slice(*PUBLIC_ATTRIBUTES)
    data["profile_picture_url"] = profile_picture.attached? ? Rails.application.routes.url_helpers.url_for(profile_picture) : nil
    data
  end

  def generate_password_reset_token!
    token = SecureRandom.uuid
    update!(reset_password_token: token, reset_password_sent_at: Time.current)
    token
  end

  def reset_token_valid?
    reset_password_sent_at.present? && reset_password_sent_at > 2.hour.ago
  end

  def clear_reset_token!
    update!(reset_password_token: nil, reset_password_sent_at: nil)
  end

  private
  def password_presence_if_local
    # Si no es Google, requiere password
    if provider.blank? && (password_digest.blank? && password.blank?)
      errors.add(:password, "no puede estar vacío")
    end
  end
end
