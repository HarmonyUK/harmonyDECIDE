Rails.application.config.after_initialize do
Decidim::Civicrm.configure do |config|
  # Configure API credentials
  config.api = {
    key: Rails.application.credentials.dig(:civicrm, :api, :api_key),
    secret: Rails.application.credentials.dig(:civicrm, :api, :site_key),
    url: Rails.application.credentials.dig(:civicrm, :api, :url)
  }

  # Configure OmniAuth secrets
  config.omniauth = {
    enabled: Rails.application.credentials.dig(:civicrm, :omniauth, :enabled),
    client_id: Rails.application.credentials.dig(:civicrm, :omniauth, :client_id),
    client_secret: Rails.application.credentials.dig(:civicrm, :omniauth, :client_secret),
    icon_path: "HarmonyLogo.png", # Ensure this file exists at app/packs/images/icon.png
    site: Rails.application.credentials.dig(:civicrm, :omniauth, :site)
  }

  # Whether to send notifications to users when they are auto-verified
  config.send_verification_notifications = false

  # Optional: enable or disable verification methods
  config.authorizations = [:civicrm, :civicrm_groups, :civicrm_membership_types]
  end
end
