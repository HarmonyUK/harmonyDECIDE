require "decidim_discord/version"
require "decidim_discord/engine"
require "decidim_discord/proposal_listener"
require "decidim_discord/amendment_listener"
require "decidim_discord/endorsement_listener"

# Add these:
require_relative "../app/services/decidim_discord/message_formatter_service"
require_relative "../app/services/decidim_discord/discord_webhook_service"

module DecidimDiscord
  # Module for Discord integration with Decidim
end
