# frozen_string_literal: true

# Configure Decidim session duration to match harmonyWEB
# harmonyWEB sessions last 7 days, so we match that duration
Decidim.configure do |config|
  # Expire Decidim sessions after 7 days to match harmonyWEB
  config.expire_session_after = 7.days

  # Enable remember_me functionality for persistent sessions
  config.enable_remember_me = true
end
