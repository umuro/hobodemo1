class EventHasSiteMigration < ActiveRecord::Migration
  def self.up
    add_column :events, :site_url, :string
    remove_column :events, :event_type

  end

  def self.down
    remove_column :events, :site_url
    add_column :events, :event_type, :string, :null => false

  end
end
