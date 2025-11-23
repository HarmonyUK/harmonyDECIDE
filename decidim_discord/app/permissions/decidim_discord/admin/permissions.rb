module DecidimDiscord
  module Admin
    class Permissions < Decidim::DefaultPermissions
      def permissions
        if user_admin? && action.subject == :discord_webhooks
          allow!
        end

        action
      end

      private

      def user_admin?
        user&.admin?
      end
    end
  end
end
