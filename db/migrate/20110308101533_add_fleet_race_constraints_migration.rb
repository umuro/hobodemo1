class AddFleetRaceConstraintsMigration < ActiveRecord::Migration
  def self.up
    change_column :countries, :name, :string, :null => false, :limit => 255

    change_column :fleet_race_memberships, :fleet_race_id, :integer, :null => false
    change_column :fleet_race_memberships, :boat_id, :integer, :null => false

    change_column :crews, :name, :string, :null => false, :limit => 255

    add_index :countries, [:name], :unique => true
    add_index :countries, [:code], :unique => true

    remove_index :event_folders, :name => :index_event_folders_on_name rescue ActiveRecord::StatementInvalid
    add_index :event_folders, [:name]

    remove_index :events, :name => :index_events_on_event_series_id rescue ActiveRecord::StatementInvalid

    add_index :crews, [:name]
  end

  def self.down
    change_column :countries, :name, :string

    change_column :fleet_race_memberships, :fleet_race_id, :integer
    change_column :fleet_race_memberships, :boat_id, :integer

    change_column :crews, :name, :string

    remove_index :countries, :name => :index_countries_on_name rescue ActiveRecord::StatementInvalid
    remove_index :countries, :name => :index_countries_on_code rescue ActiveRecord::StatementInvalid

    remove_index :event_folders, :name => :index_event_folders_on_name rescue ActiveRecord::StatementInvalid
    add_index :event_folders, [:name], :unique => true

    add_index :events, [:event_folder_id], :name => 'index_events_on_event_series_id'

    remove_index :crews, :name => :index_crews_on_name rescue ActiveRecord::StatementInvalid
  end
end
