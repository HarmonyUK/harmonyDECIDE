class CreateDecidimDiscordWebhooks < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_discord_webhooks do |t|
      t.string :name, null: false
      t.string :webhook_url, null: false
      t.json :event_types, default: []
      t.boolean :active, default: true
      t.text :description

      t.timestamps
    end

    add_index :decidim_discord_webhooks, :active
    add_index :decidim_discord_webhooks, :webhook_url, unique: true

    create_table :decidim_discord_webhook_logs do |t|
      t.bigint :discord_webhook_id, foreign_key: true
      t.string :event_type
      t.integer :status
      t.text :response_body
      t.boolean :success, default: false

      t.timestamps
    end

    add_foreign_key :decidim_discord_webhook_logs, :decidim_discord_webhooks, column: :discord_webhook_id
    add_index :decidim_discord_webhook_logs, :discord_webhook_id, name: "idx_webhook_logs_webhook"
    add_index :decidim_discord_webhook_logs, :created_at, name: "idx_webhook_logs_created"
    add_index :decidim_discord_webhook_logs, :success, name: "idx_webhook_logs_success"
  end
end
