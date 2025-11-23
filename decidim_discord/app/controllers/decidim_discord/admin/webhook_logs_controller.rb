module DecidimDiscord
  module Admin
    class WebhookLogsController < ApplicationController
      layout "decidim/admin/application"
      helper_method :webhook, :logs

      def index
        @logs = webhook.webhook_logs.recent
      end

      def show
        @log = webhook.webhook_logs.find(params[:id])
      end

      private

      def webhook
        @webhook ||= DecidimDiscord::DiscordWebhook.find(params[:discord_webhook_id])
      end
    end
  end
end
