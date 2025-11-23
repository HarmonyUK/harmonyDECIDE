require "sidekiq/web"
Rails.application.routes.draw do
  mount Decidim::Core::Engine => '/'
  mount DecidimDiscord::Engine => '/'
  mount DecidimZoom::Engine => '/'
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end
  post 'webhooks/buttondown', to: 'webhooks/buttondown#create'
end
