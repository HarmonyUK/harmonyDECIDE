Rails.application.config.session_store :cookie_store, key: '_decidim_session', domain: :all, same_site: :lax, secure: true
