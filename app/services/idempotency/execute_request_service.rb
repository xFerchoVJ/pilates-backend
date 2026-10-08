require "digest"

class Idempotency::ExecuteRequestService
  class ConflictError < StandardError; end

  def initialize(user:, endpoint:, key:, payload:)
    @user = user
    @endpoint = endpoint
    @key = key.to_s.strip
    @fingerprint = Digest::SHA256.hexdigest(JSON.generate(canonicalize(payload.to_h)))
  end

  def call
    request, created = find_or_create_request
    replay = prepare_request(request, created)
    return replay if replay

    result = yield(request)
    request.update!(
      status: "completed",
      response_body: result.fetch(:body),
      response_status: result.fetch(:status),
      expires_at: IdempotencyRequest::RETENTION_PERIOD.from_now
    )
    result.merge(replayed: false)
  end

  private

  def find_or_create_request
    request = IdempotencyRequest.create!(
      user: @user,
      endpoint: @endpoint,
      key: @key,
      request_fingerprint: @fingerprint,
      status: "processing",
      expires_at: IdempotencyRequest::RETENTION_PERIOD.from_now
    )
    [ request, true ]
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    request = IdempotencyRequest.find_by!(key: @key)
    [ request, false ]
  end

  def prepare_request(request, created)
    return nil if created

    request.with_lock do
      if request.user_id != @user.id || request.endpoint != @endpoint
        raise ConflictError, "La clave de idempotencia ya fue utilizada en otra operación"
      end

      if request.expires_at <= Time.current
        request.update!(
          request_fingerprint: @fingerprint,
          status: "processing",
          response_body: nil,
          response_status: nil,
          expires_at: IdempotencyRequest::RETENTION_PERIOD.from_now
        )
        return nil
      end

      raise ConflictError, "La clave de idempotencia fue reutilizada con parámetros diferentes" if request.request_fingerprint != @fingerprint

      if request.completed?
        return {
          body: request.response_body.deep_symbolize_keys,
          status: request.response_status,
          replayed: true
        }
      end

      raise ConflictError, "Ya existe una solicitud en proceso con esta clave de idempotencia"
    end
  end

  def canonicalize(value)
    case value
    when Hash
      value.each_with_object({}) { |(key, item), result| result[key.to_s] = canonicalize(item) }
           .sort.to_h
    when Array
      value.map { |item| canonicalize(item) }
    else
      value
    end
  end
end
