Decidim::Civicrm.configure do |config|
  config.client_id = ENV["CIVICRM_CLIENT_ID"]
  config.client_secret = ENV["CIVICRM_CLIENT_SECRET"]
  config.site = ENV["CIVICRM_SITE"]
  config.scope = "openid profile email"  # Space-separated
  config.redirect_uri = "https://decide.harmonyuk.org/users/auth/civicrm/callback"
  config.authorize_url = "/oauth2/authorize"
  config.token_url = "/oauth2/token"
end
