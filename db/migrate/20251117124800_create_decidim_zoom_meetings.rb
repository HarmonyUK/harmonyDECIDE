class CreateDecidimZoomMeetings < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_zoom_meetings do |t|
      t.references :decidim_meeting, foreign_key: { to_table: :decidim_meetings_meetings }, index: true, null: false
      t.string :zoom_meeting_id, null: false
      t.string :zoom_meeting_password
      t.text :join_url, null: false
      t.text :start_url, null: false
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index :zoom_meeting_id, unique: true
    end
  end
end
