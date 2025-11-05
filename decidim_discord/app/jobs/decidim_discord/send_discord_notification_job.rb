module DecidimDiscord
  class SendDiscordNotificationJob < ApplicationJob
    queue_as :default

    def perform(webhook_id, event_type, payload)
      webhook = DecidimDiscord::DiscordWebhook.find(webhook_id)
      return unless webhook.active?

      # Inline message formatting for now
      message = {
        content: nil,
        embeds: [
          {
            title: "📝 New Proposal Created",
            description: payload[:proposal_title],
            color: 0x3498db,
            fields: [
              { name: "Assembly", value: payload[:assembly_name], inline: true },
              { name: "Component", value: payload[:component_name], inline: true },
              { name: "Author", value: payload[:author_name], inline: true },
              { name: "URL", value: "[View Proposal](#{payload[:proposal_url]})", inline: false }
            ],
            timestamp: Time.current.iso8601
          }
        ]
      }
      
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
