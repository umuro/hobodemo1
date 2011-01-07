class EventFoldersMigration < ActiveRecord::Migration
  def self.up
    rename_table :event_series, :event_folders

    rename_column :events, :event_series_id, :event_folder_id

    remove_index :event_folders, :name => :index_event_series_on_organization_id rescue ActiveRecord::StatementInvalid
    remove_index :event_folders, :name => :index_event_series_on_name rescue ActiveRecord::StatementInvalid
    add_index :event_folders, [:name], :unique => true
    add_index :event_folders, [:organization_id]

    add_index :events, [:name]
    add_index :events, [:event_folder_id]

  end

  def self.down
    rename_column :events, :event_folder_id, :event_series_id

    rename_table :event_folders, :event_series

    remove_index :event_series, :name => :index_event_folders_on_name rescue ActiveRecord::StatementInvalid
    remove_index :event_series, :name => :index_event_folders_on_organization_id rescue ActiveRecord::StatementInvalid
    add_index :event_series, [:organization_id]
    add_index :event_series, [:name], :unique => true
  end
end
