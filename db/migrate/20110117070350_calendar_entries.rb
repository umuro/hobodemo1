class CalendarEntries < ActiveRecord::Migration
  def self.up
    create_table :calendar_entries do |t|
      t.string   :name
      t.datetime :scheduled_time
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :event_id, :null => false
    end
    add_index :calendar_entries, [:event_id]
  end

  def self.down
    drop_table :calendar_entries
  end
end
