module DecidimDiscord
  class DiscordWebhook < ApplicationRecord
    self.table_name = "decidim_discord_webhooks"

    validates :webhook_url, :name, presence: true
    validates :webhook_url, format: {
      with: %r{\Ahttps://(?:discordapp|discord)\.com/api/webhooks/},
      message: "must be a valid Discord webhook URL"
    }

    scope :active, -> { where(active: true) }
    scope :for_event, ->(event_type) { where("event_types::jsonb @> ?::jsonb", [event_type.to_s].to_json) }

    has_many :webhook_logs, class_name: "DecidimDiscord::WebhookLog",
                            foreign_key: "discord_webhook_id",
                            dependent: :destroy

    def toggle!
      update(active: !active)
    end

    def log_success(event_type)
      webhook_logs.create(
        event_type: event_type,
        status: 200,
        response_body: "Success",
        success: true
      )
    end
  end
end
