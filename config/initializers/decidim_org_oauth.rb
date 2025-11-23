# config/initializers/decidim_org_oauth.rb
# Organization-specific OAuth configuration for multi-tenant Decidim
# 
# This allows different organizations to use different Keycloak instances
# or different OAuth providers entirely.

Rails.application.config.to_prepare do
  # Configuration hash mapping organization hosts to their OAuth settings
  ORGANIZATION_OAUTH_CONFIGS = {
    'decide.harmonyuk.org' => {
      keycloakopenid: {
        enabled: ENV['HARMONYUK_KEYCLOAK_ENABLED']&.downcase == 'true',
        icon_path: 'media/images/keycloak_logo.svg',
        client_id: ENV['HARMONYUK_KEYCLOAK_CLIENT_ID'],
        client_secret: ENV['HARMONYUK_KEYCLOAK_CLIENT_SECRET'],
        site: ENV['HARMONYUK_KEYCLOAK_SITE'],
        realm: ENV['HARMONYUK_KEYCLOAK_REALM'],
        base_url: ENV.fetch('HARMONYUK_KEYCLOAK_BASE_URL', '/auth')
      }
    },
    'decide.nothingabout.us' => {
      keycloakopenid: {
        enabled: ENV['NAU_KEYCLOAK_ENABLED']&.downcase == 'true',
        icon_path: 'media/images/keycloak_logo.svg',
        client_id: ENV['NAU_KEYCLOAK_CLIENT_ID'],
        client_secret: ENV['NAU_KEYCLOAK_CLIENT_SECRET'],
        site: ENV['NAU_KEYCLOAK_SITE'],
        realm: ENV['NAU_KEYCLOAK_REALM'],
        base_url: ENV.fetch('NAU_KEYCLOAK_BASE_URL', '/auth')
      }
      # If NAU doesn't use Keycloak, you could add other providers:
      # google_oauth2: {
      #   enabled: ENV['NAU_GOOGLE_ENABLED']&.downcase == 'true',
      #   icon_path: 'media/images/google.svg',
      #   client_id: ENV['NAU_GOOGLE_CLIENT_ID'],
      #   client_secret: ENV['NAU_GOOGLE_CLIENT_SECRET']
      # }
    }
  }.freeze

  # Helper method to get OAuth config for a specific organization
  module OrganizationOmniauthHelper
    def self.config_for(organization)
      return {} unless organization
      
      host = organization.host
      config = ORGANIZATION_OAUTH_CONFIGS[host]
      
      return {} unless config
      
      # Filter out disabled providers and return in format Decidim expects
      enabled_providers = config.select do |provider, settings| 
        settings[:enabled] == true && 
        settings[:client_id].present? && 
        settings[:client_secret].present?
      end
      
      enabled_providers
    end
  end

  # Override Decidim's OmniAuth configuration lookup
  # This is the key part that makes organization-specific OAuth work
  
  # Patch the secrets loading for omniauth
  Rails.application.secrets.singleton_class.class_eval do
    def omniauth
      # Get the current organization from the request
      # This uses Thread.current which Decidim sets during request processing
      organization = Thread.current[:current_organization] || 
                    RequestStore.store[:current_organization]
      
      if organization
        org_config = OrganizationOmniauthHelper.config_for(organization)
        return org_config if org_config.any?
      end
      
      # Fall back to the default configuration from secrets.yml
      # if organization-specific config is not found
      self[:omniauth] || {}
    end
  end

  # Alternative: Override at the Decidim level
  # This may be more reliable depending on your Decidim version
  if defined?(Decidim::OmniauthProvider)
    Decidim::OmniauthProvider.class_eval do
      class << self
        # Override the providers method to use organization-specific config
        def providers_for(organization)
          org_config = OrganizationOmniauthHelper.config_for(organization)
          
          if org_config.any?
            # Convert to the format Decidim expects
            org_config.map do |name, settings|
              new(
                name: name.to_s,
                enabled: settings[:enabled],
                icon: settings[:icon_path] || settings[:icon],
                # Pass through all other settings
                **settings.except(:enabled, :icon_path, :icon)
              )
            end
          else
            # Fall back to default behavior
            available_providers.select do |provider|
              provider.enabled? && organization.enabled_omniauth_providers.key?(provider.name.to_sym)
            end
          end
        end
      end
    end
  end

  # Store current organization in thread/request store for access in secrets
  # This ensures the organization context is available when OAuth config is loaded
  Decidim::CurrentOrganization.class_eval do
    def call(env)
      organization = detect_organization(env)
      Thread.current[:current_organization] = organization
      RequestStore.store[:current_organization] = organization
      
      result = @app.call(env)
      
      # Clean up
      Thread.current[:current_organization] = nil
      RequestStore.store[:current_organization] = nil
      
      result
    end
  end if defined?(Decidim::CurrentOrganization)

  Rails.logger.info "✓ Organization-specific OAuth configuration loaded"
  Rails.logger.info "  Configured organizations: #{ORGANIZATION_OAUTH_CONFIGS.keys.join(', ')}"
end
