# db/migrate/[timestamp]_create_buttondown_census.rb
class CreateButtondownCensus < ActiveRecord::Migration[6.1]
  def change
    create_table :buttondown_census_entries do |t|
      t.string :email, null: false
      t.references :organization, foreign_key: { to_table: :decidim_organizations }
      t.datetime :subscribed_at
      t.jsonb :metadata, default: {}
      t.timestamps
      
      t.index [:email, :organization_id], unique: true
    end
  end
end
