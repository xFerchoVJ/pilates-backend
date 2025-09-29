class BlacklistedToken < ApplicationRecord
  validates :jti, presence: true, uniqueness: true
  validates :exp, presence: true

  scope :active, -> { where("exp > ?", Time.current) }

  def self.blacklist!(jti, exp)
    find_or_create_by(jti: jti) do |token|
      token.exp = exp
    end
  end

  def self.blacklisted?(jti)
    active.exists?(jti: jti)
  end

  # Limpiar tokens expirados periódicamente
  def self.cleanup_expired!
    where("exp <= ?", Time.current).delete_all
  end
end
