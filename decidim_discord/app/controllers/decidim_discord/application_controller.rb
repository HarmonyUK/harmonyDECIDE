module DecidimDiscord
  class ApplicationController < Decidim::Admin::ApplicationController
    protect_from_forgery with: :exception

    protected

    def permission_class
      DecidimDiscord::Admin::Permissions
    end
  end
end
