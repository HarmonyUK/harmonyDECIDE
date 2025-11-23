module DecidimDiscord
  module Admin
    class ApplicationController < Decidim::Admin::ApplicationController
      helper_method :current_user

      before_action :ensure_admin!

      protected

    def ensure_admin!
      Rails.logger.info "=== Checking admin permissions ==="
      Rails.logger.info "=== Current user: #{current_user&.inspect} ==="
      Rails.logger.info "=== Is admin?: #{current_user&.admin?} ==="
      raise Decidim::ActionForbidden unless current_user&.admin?
      end
    end
  end
end
