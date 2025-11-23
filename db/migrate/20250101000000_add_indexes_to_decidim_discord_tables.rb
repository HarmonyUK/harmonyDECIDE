class AddIndexesToDecidimDiscordTables < ActiveRecord::Migration[7.0]
  def change
    # Only add indexes if they don't exist
    unless index_exists?(:decidim_discord_webhooks, [:active], name: 'index_decidim_discord_webhooks_on_active')
      add_index :decidim_discord_webhooks, [:active], name: 'index_decidim_discord_webhooks_on_active'
    end
    
    unless index_exists?(:decidim_discord_webhooks, [:active, :id], name: 'index_decidim_discord_webhooks_on_active_and_id')
      add_index :decidim_discord_webhooks, [:active, :id], name: 'index_decidim_discord_webhooks_on_active_and_id'
    end
    
    unless index_exists?(:decidim_discord_webhook_logs, [:discord_webhook_id], name: 'index_webhook_logs_on_webhook_id')
      add_index :decidim_discord_webhook_logs, [:discord_webhook_id], name: 'index_webhook_logs_on_webhook_id'
    end
    
    unless index_exists?(:decidim_discord_webhook_logs, [:success], name: 'index_webhook_logs_on_success')
      add_index :decidim_discord_webhook_logs, [:success], name: 'index_webhook_logs_on_success'
    end
    
    unless index_exists?(:decidim_discord_webhook_logs, [:created_at], name: 'index_webhook_logs_on_created_at')
      add_index :decidim_discord_webhook_logs, [:created_at], name: 'index_webhook_logs_on_created_at'
    end
    
    unless index_exists?(:decidim_discord_webhook_logs, [:discord_webhook_id, :created_at], name: 'index_webhook_logs_on_webhook_id_and_created_at')
      add_index :decidim_discord_webhook_logs, [:discord_webhook_id, :created_at], name: 'index_webhook_logs_on_webhook_id_and_created_at'
    end
  end
end
