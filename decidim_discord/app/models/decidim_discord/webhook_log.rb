module DecidimDiscord
  class WebhookLog < ApplicationRecord
    self.table_name = "decidim_discord_webhook_logs"

    belongs_to :discord_webhook, class_name: "DecidimDiscord::DiscordWebhook"

    scope :recent, -> { order(created_at: :desc).limit(100) }
    scope :failed, -> { where(success: false) }
  end
end
