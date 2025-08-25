class JwtService
  ALGO = "HS256".freeze

  def self.access_exp
    15.minutes
  end

  def self.refresh_exp
    30.days
  end

  def self.encode(payload, exp:)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret, ALGO)
  end

  def self.decode(token)
    body, = JWT.decode(token, secret, true, { algorithm: ALGO })
    body.with_indifferent_access
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.secret
    Rails.application.credentials.jwt_secret || ENV["JWT_SECRET"]
  end
end
