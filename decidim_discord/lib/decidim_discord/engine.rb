require "httparty"

module DecidimDiscord
  class Engine < ::Rails::Engine
    engine_name "decidim_discord"
    isolate_namespace DecidimDiscord

    initializer "decidim_discord.listeners" do
      config.to_prepare do
        DecidimDiscord::ProposalListener.attach
        DecidimDiscord::AmendmentListener.attach
        DecidimDiscord::EndorsementListener.attach
      end
    end

    initializer "decidim_discord.menu", before: :build_menu do
      Decidim.menu :admin_menu do |menu|
        menu.item I18n.t("menu", scope: "decidim.decidim_discord.admin"),
                  "/admin/discord_webhooks",
                  icon_name: "settings-line",
                  position: 8,
                  active: :inclusive,
                  if: -> { current_user&.admin? }
      end
    end
  end
end
