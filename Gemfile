# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "0.29.5"
# gem "decidim-ai", "0.30.1"
gem "decidim-conferences", "0.29.5"
#gem "decidim-plans"
#gem "decidim-design", "0.29.5"
#gem "decidim-initiatives", "0.29.5"
#gem "decidim-templates", "0.29.5" 
#gem "decidim-spam_signal", "~> 0.4.0"
gem "pg"
gem "mutex_m"
gem "bootsnap", "~> 1.3"
gem "figaro"
gem "dotenv"
gem "puma", ">= 6.3.1"
gem 'pusher', '~> 1.3'
gem "daemons"
gem 'mailtrap'
gem "passenger"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 7.0"
  gem "decidim-dev", "0.29.5"
  gem "net-imap", "~> 0.5.0"
  gem "net-pop", "~> 0.1.1"
end

group :development do
# gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.2"
end
gem "sidekiq"
group :production do
gem "decidim-civicrm", "~> 0.8", github: "openpoke/decidim-module-civicrm"
end

#gem "decidim-ai", "~> 0.30.1"
