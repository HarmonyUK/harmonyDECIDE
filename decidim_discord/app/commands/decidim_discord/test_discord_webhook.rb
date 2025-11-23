module DecidimDiscord
  class TestDiscordWebhook < Decidim::Command
    def initialize(webhook)
      @webhook = webhook
    end

    def call
      payload = {
        proposal_title: "Test Proposal from Admin Interface",
        proposal_url: "https://decide.harmonyuk.org/test",
        assembly_name: "Test Assembly",
        component_name: "Test Component",
        author_name: "Administrator",
        created_at: Time.current.iso8601
      }

      SendDiscordNotificationJob.perform_now(@webhook.id, :proposal_created, payload)
      broadcast(:ok)
    rescue StandardError => e
      Rails.logger.error "Test webhook failed: #{e.message}"
      broadcast(:invalid)
    end
  end
end
