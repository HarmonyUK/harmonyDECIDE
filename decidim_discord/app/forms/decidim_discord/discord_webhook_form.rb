module DecidimDiscord
  class DiscordWebhookForm < Decidim::Form
    attribute :name, String
    attribute :webhook_url, String
    attribute :event_types, Array[String]
    attribute :active, Boolean, default: true

    validates :name, presence: true, length: { minimum: 3, maximum: 255 }
    validates :webhook_url, presence: true, format: {
      with: %r{\Ahttps://(?:discordapp|discord)\.com/api/webhooks/},
      message: I18n.t("errors.invalid_discord_webhook", scope: "decidim.decidim_discord")
    }
    validates :event_types, presence: true

    def event_types_options
      [
        [I18n.t("event_types.proposal_created", scope: "decidim.decidim_discord"), "proposal_created"],
        [I18n.t("event_types.proposal_status_changed", scope: "decidim.decidim_discord"), "proposal_status_changed"],
        [I18n.t("event_types.amendment_created", scope: "decidim.decidim_discord"), "amendment_created"],
        [I18n.t("event_types.endorsement_milestone", scope: "decidim.decidim_discord"), "endorsement_milestone"]
      ]
    end

    def map_model(model)
      self.event_types = model.event_types || []
      self.active = model.active
    end
  end
end
