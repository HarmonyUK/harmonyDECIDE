class CreateDecidimDiscordTables < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_discord_webhooks do |t|
      t.string :name, null: false
      t.string :webhook_url, null: false
      t.jsonb :event_types, default: [], null: false
      t.boolean :active, default: true
      t.timestamps
    end
    
    add_index :decidim_discord_webhooks, :created_at

    create_table :decidim_discord_webhook_logs do |t|
      t.references :discord_webhook, foreign_key: { to_table: :decidim_discord_webhooks }
      t.string :event_type
      t.integer :status
      t.text :response_body
      t.boolean :success, default: false
      t.timestamps
    end
    
    add_index :decidim_discord_webhook_logs, [:discord_webhook_id, :created_at]
  end
end
