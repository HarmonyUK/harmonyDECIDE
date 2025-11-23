class AddFieldsToButtondownCensus < ActiveRecord::Migration[7.0]
  def change
    add_column :buttondown_census_entries, :subscriber_id, :string unless column_exists?(:buttondown_census_entries, :subscriber_id)
    add_column :buttondown_census_entries, :active, :boolean, default: true unless column_exists?(:buttondown_census_entries, :active)
    
    add_index :buttondown_census_entries, :subscriber_id unless index_exists?(:buttondown_census_entries, :subscriber_id)
  end
end
