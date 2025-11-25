Rails.application.config.session_store :cookie_store,
  key: '_decidim_session',
  domain: :all,
  same_site: :lax,
  secure: true,
  expire_after: 7.days  # Match harmonyWEB session duration (604800 seconds)
