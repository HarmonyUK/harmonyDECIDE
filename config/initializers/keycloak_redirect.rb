Rails.application.config.to_prepare do
  # Override the Devise sessions controller to auto-redirect
  Decidim::Devise::SessionsController.class_eval do
    before_action :redirect_to_auth, only: [:new]

    private

    def redirect_to_auth
      # Check if user is not already authenticated
      return if user_signed_in?

      # For HarmonyUK organization, redirect to harmonyWEB unified login
      if current_organization.host == 'decide.harmonyuk.org'
        redirect_to_harmony_web
      # For other organizations with Keycloak, use standard OAuth
      elsif current_organization.enabled_omniauth_providers.key?(:keycloakopenid)
        redirect_to_keycloak
      end
    end

    def redirect_to_harmony_web
      # Build the callback URL where harmonyWEB should redirect back
      # IMPORTANT: Redirect back to /users/sign_in so authentication check runs
      callback_url = decidim.user_session_url(host: request.host, protocol: request.protocol)

      # Redirect to harmonyWEB login page with callback URL
      harmony_login_url = "https://harmonyuk.org/login?redirect_uri=#{CGI.escape(callback_url)}"

      Rails.logger.info("HarmonyAuth: Redirecting to harmonyWEB with callback: #{callback_url}")
      redirect_to harmony_login_url, allow_other_host: true
    end

    def redirect_to_keycloak
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
