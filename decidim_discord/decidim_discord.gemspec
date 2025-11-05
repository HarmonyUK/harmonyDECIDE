$LOAD_PATH.push File.expand_path("lib", __dir__)
require "decidim_discord/version"

Gem::Specification.new do |s|
  s.name        = "decidim_discord"
  s.version     = "0.0.1"
  s.authors     = ["John Urquhart?"]
  s.email       = ["your.email@example.com"]
  s.homepage    = "https://github.com/yourusername/decidim-discord"
  s.summary     = "Discord integration for Decidim"
  s.license     = "AGPL-3.0"

  s.files = Dir["{app,config,db,lib}/**/*", "README.md"]

  s.add_dependency "rails", "~> 7.0"
  s.add_dependency "decidim", "0.29.5"
  s.add_dependency "httparty", "~> 0.23"

  s.add_development_dependency "rspec-rails"
end
