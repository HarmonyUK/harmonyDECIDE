module DecidimDiscord
  module Admin
    class DiscordWebhooksController < ApplicationController
      helper_method :webhooks, :webhook
      layout "decidim/admin/application"

      def index
        Rails.logger.info "=== DiscordWebhooksController#index called ==="
        @webhooks = DecidimDiscord::DiscordWebhook.order(created_at: :desc)
        Rails.logger.info "=== Found #{@webhooks.count} webhooks ==="
      end

      def new
        @form = form(DiscordWebhookForm).instance
      end

      def create
        @form = form(DiscordWebhookForm).from_params(params)

        CreateDiscordWebhook.call(@form) do
          on(:ok) do |webhook|
            flash[:notice] = I18n.t("discord_webhooks.create.success", scope: "decidim.decidim_discord.admin")
            redirect_to admin_discord_webhooks_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("discord_webhooks.create.error", scope: "decidim.decidim_discord.admin")
            render :new
          end
        end
      end

      def edit
        @form = form(DiscordWebhookForm).from_model(webhook)
      end

      def update
        @form = form(DiscordWebhookForm).from_params(params)

        UpdateDiscordWebhook.call(@form, webhook) do
          on(:ok) do
            flash[:notice] = I18n.t("discord_webhooks.update.success", scope: "decidim.decidim_discord.admin")
            redirect_to admin_discord_webhooks_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("discord_webhooks.update.error", scope: "decidim.decidim_discord.admin")
            render :edit
          end
        end
      end

      def destroy
        webhook.destroy!
        flash[:notice] = I18n.t("discord_webhooks.destroy.success", scope: "decidim.decidim_discord.admin")
        redirect_to admin_discord_webhooks_path
      end

      def toggle
        webhook.toggle!
        flash[:notice] = I18n.t(
          "discord_webhooks.toggle.#{webhook.active? ? 'activated' : 'deactivated'}",
          scope: "decidim.decidim_discord.admin"
        )
        redirect_to admin_discord_webhooks_path
      end

      def test
        TestDiscordWebhook.call(webhook) do
          on(:ok) do
            flash[:notice] = I18n.t("discord_webhooks.test.success", scope: "decidim.decidim_discord.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("discord_webhooks.test.error", scope: "decidim.decidim_discord.admin")
          end
        end
        redirect_to admin_discord_webhooks_path
      end

      private

      def webhook
        @webhook ||= DecidimDiscord::DiscordWebhook.find(params[:id])
      end
    end
  end
end
