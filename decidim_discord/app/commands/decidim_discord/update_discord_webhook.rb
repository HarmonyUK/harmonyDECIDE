module DecidimDiscord
  class UpdateDiscordWebhook < Decidim::Command
    def initialize(form, webhook)
      @form = form
      @webhook = webhook
    end

    def call
      return broadcast(:invalid) if @form.invalid?

      @webhook.update(
        name: @form.name,
        webhook_url: @form.webhook_url,
        event_types: @form.event_types,
        active: @form.active
      )

      if @webhook.save
        broadcast(:ok, @webhook)
      else
        broadcast(:invalid)
      end
    end
  end
end
