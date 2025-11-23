DecidimDiscord::Engine.routes.draw do
  namespace :admin do
    resources :discord_webhooks do
      member do
        post :toggle
        post :test
      end
      resources :webhook_logs, only: [:index, :show]
    end
  end
end
