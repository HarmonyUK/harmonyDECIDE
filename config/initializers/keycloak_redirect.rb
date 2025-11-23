Rails.application.config.to_prepare do
  # Override the Devise sessions controller to auto-redirect to Keycloak
  Decidim::Devise::SessionsController.class_eval do
    before_action :redirect_to_keycloak, only: [:new]

    private

    def redirect_to_keycloak
      # Check if user is not already authenticated
      return if user_signed_in?

      # Check if Keycloak is enabled as an OmniAuth provider
      if current_organization.enabled_omniauth_providers.key?(:keycloakopenid)
        # Render a form that auto-submits to the OmniAuth POST endpoint
        render inline: <<~ERB
          <!DOCTYPE html>
          <html>
            <head>
              <title>Redirecting to Keycloak...</title>
            </head>
            <body onload="document.forms[0].submit();">
              <form method="POST" action="<%= decidim.user_keycloakopenid_omniauth_authorize_path %>">
                <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
              </form>
              <noscript>
                <p>JavaScript is disabled. <a href="<%= decidim.user_keycloakopenid_omniauth_authorize_path %>">Click here to continue.</a></p>
              </noscript>
            </body>
          </html>
        ERB
      end
    end
  end
end
