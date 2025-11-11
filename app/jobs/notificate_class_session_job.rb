class NotificateClassSessionJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "[#{Time.current}] NotificateClassSessionJob started"
    one_hour_from_now = 1.hour.from_now.in_time_zone
    time_range_start = one_hour_from_now - 5.minutes
    time_range_end = one_hour_from_now + 5.minutes

    upcoming_classes = ClassSession
      .where(start_time: time_range_start..time_range_end)
      .upcoming
    Rails.logger.info "[#{Time.current}] Upcoming classes: #{upcoming_classes.inspect}"

    return if upcoming_classes.empty?

    Rails.logger.info "[#{Time.current}] Found #{upcoming_classes.count} classes starting in ~1 hour"

    upcoming_classes.each { |class_session| notify_users_for_class(class_session) }
  end

  private

  def notify_users_for_class(class_session)
    reservations = class_session.reservations.includes(:user)
    return if reservations.empty?

    time_until_class = class_session.start_time - Time.current
    return if time_until_class <= 0

    users_to_notify = []
    tokens_to_send = []

    reservations.each do |reservation|
      user = reservation.user
      user_cache_key = "user_notified:#{user.id}:#{class_session.id}"

      was_already_notified = Rails.cache.fetch(user_cache_key, expires_in: time_until_class) { nil }
      next if was_already_notified.present?

      user_tokens = Device.where(user_id: user.id).pluck(:expo_push_token).compact
      next if user_tokens.empty?

      users_to_notify << user
      tokens_to_send.concat(user_tokens)
    end

    return if tokens_to_send.empty?

    title = "Recordatorio de clase"
    body = "Tu clase '#{class_session.name}' comienza en 1 hora"
    data = {
      type: "class_reminder",
      class_session_id: class_session.id,
      start_time: class_session.start_time.iso8601
    }

    service = Notifications::PushNotificationsService.new(tokens: tokens_to_send, title: title, body: body, data: data)
    result = service.call

    if result[:success]
      users_to_notify.each do |user|
        Rails.cache.write("user_notified:#{user.id}:#{class_session.id}", true, expires_in: time_until_class)
      end
      Rails.logger.info "✅ Sent notifications to #{tokens_to_send.count} devices (#{users_to_notify.count} users) for class #{class_session.id}"
    else
      users_to_notify.each { |user| Rails.cache.delete("user_notified:#{user.id}:#{class_session.id}") }
      Rails.logger.error "❌ Failed notifications for class #{class_session.id}: #{result[:errors]}"
    end
  end
end
