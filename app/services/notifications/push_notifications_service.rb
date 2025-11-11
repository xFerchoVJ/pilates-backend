# app/services/notifications/push_notifications_service.rb
class Notifications::PushNotificationsService
  def initialize(tokens:, title:, body:, data: {})
    @client = Exponent::Push::Client.new
    @tokens = tokens
    @title = title
    @body = body
    @data = data
  end

  def call
    messages = @tokens.map do |token|
      next unless token.present?

      {
        to: "ExponentPushToken[#{token}]",
        title: @title,
        body: @body,
        data: @data,
        sound: "default",
        priority: "high"
      }
    end.compact

    return { success: false, errors: [ "No valid tokens" ] } if messages.empty?

    handler = @client.send_messages(messages)

    if handler.errors.empty?
      receipts = @client.verify_deliveries(handler.receipt_ids)
      { success: true, receipts: receipts }
    else
      { success: false, errors: handler.errors }
    end
  end
end
