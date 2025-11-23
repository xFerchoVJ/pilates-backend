class DeactivePastClassPackagesJob
  include Sidekiq::Job

  def perform
    past_packages = UserClassPackage.where("expires_at <= ?", Time.current)
    past_packages.update_all(status: "inactive")
  end
end
