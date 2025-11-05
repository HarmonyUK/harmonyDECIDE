# app/services/decidim_discord/discord_webhook_service.rb
module DecidimDiscord
  class DiscordWebhookService
    def self.notify(event_type, payload)
      new(event_type, payload).call
    end

    def initialize(event_type, payload)
      @event_type = event_type
      @payload = payload
    end

    def call
      webhooks = DecidimDiscord::DiscordWebhook.active.for_event(@event_type)
      
      webhooks.each do |webhook|
        SendDiscordNotificationJob.perform_later(webhook.id, @event_type, @payload)
      end
    end
  end
end
