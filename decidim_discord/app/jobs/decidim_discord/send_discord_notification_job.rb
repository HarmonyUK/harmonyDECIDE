module DecidimDiscord
  class SendDiscordNotificationJob < ApplicationJob
    queue_as :default

    def perform(webhook_id, event_type, payload)
      webhook = DecidimDiscord::DiscordWebhook.find(webhook_id)
      return unless webhook.active?

      message = DecidimDiscord::MessageFormatterService.format(event_type.to_sym, payload)
      
      response = HTTParty.post(
        webhook.webhook_url,
        body: message.to_json,
        headers: { "Content-Type" => "application/json" },
        timeout: 10
      )

      unless response.success?
        DecidimDiscord::WebhookLog.create(
          discord_webhook_id: webhook_id,
          event_type: event_type,
          status: response.code,
          response_body: response.body,
          success: false
        )
      end
    rescue StandardError => e
      DecidimDiscord::WebhookLog.create(
        discord_webhook_id: webhook_id,
        event_type: event_type,
        status: 0,
        response_body: e.message,
        success: false
      )
      raise
    end
  end
end
