class CleanupIdempotencyRequestsJob
  include Sidekiq::Job

  def perform
    IdempotencyRequest.where("expires_at <= ?", Time.current).delete_all
  end
end
