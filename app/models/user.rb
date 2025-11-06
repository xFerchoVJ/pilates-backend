class User < ApplicationRecord
  has_secure_password validations: false
  has_one_attached :profile_picture
  has_many :injuries, dependent: :destroy
  has_many :user_class_packages, dependent: :destroy
  has_many :refresh_token_users, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :transactions, dependent: :destroy

  enum role: { user: 0, instructor: 1, admin: 2 }

  enum gender: { male: "hombre", female: "mujer", other: "otro" }
  enum has_injuries: { pending: "pending", yes: "yes", no: "no" }

  # Query scopes for filtering
  scope :search_text, ->(term) {
    t = "%#{term}%"
    where("name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", t, t, t)
  }

  scope :by_role, ->(role_value) { where(role: role_value) }
  scope :by_gender, ->(gender_value) { where(gender: gender_value) }
  scope :created_from, ->(date) { where("created_at >= ?", date.beginning_of_day) }
  scope :created_to, ->(date) { where("created_at <= ?", date.end_of_day) }
  scope :with_injuries_state, ->(state) { where(has_injuries: state) }

  validates :email, presence: { message: "El email es requerido" }, uniqueness: { message: "El email ya está en uso" }
  validates :password,
    presence: { message: "La contraseña es obligatoria" },
    length: { minimum: 6, message: "La contraseña debe tener al menos 6 caracteres" },
    if: -> { new_record? || password.present? }
  validate :password_presence_if_local
  validates :birthdate, presence: { message: "La fecha de nacimiento es requerida" }
  validates :gender, presence: { message: "El género es requerido" }
  validates :name, presence: { message: "El nombre es requerido" }
  validates :last_name, presence: { message: "El apellido es requerido" }
  validates :phone, presence: { message: "El teléfono es requerido" }
  validates :role, presence: { message: "El rol es requerido" }

  before_update :purge_old_profile_picture, if: :profile_picture_changed?


  def generate_password_reset_token!
    token = SecureRandom.alphanumeric(6).upcase
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
  def profile_picture_changed?
    profile_picture.attached? && profile_picture.blob_id_changed?
  end

  def purge_old_profile_picture
    # Purga la imagen anterior de Cloudinary de manera segura
    profile_picture.purge_later
  end


  def password_presence_if_local
    # Si no es Google, requiere password
    if provider.blank? && (password_digest.blank? && password.blank?)
      errors.add(:password, "no puede estar vacío")
    end
  end

  def password_required?
  end
end
