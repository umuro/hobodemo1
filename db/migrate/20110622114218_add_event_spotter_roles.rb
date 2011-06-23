class AddEventSpotterRoles < ActiveRecord::Migration
  def self.up
    create_table :event_spotter_roles do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :event_id, :null => false
      t.integer  :user_id, :null => false
    end
    add_index :event_spotter_roles, [:event_id]
    add_index :event_spotter_roles, [:user_id]
    add_index :event_spotter_roles, [:event_id, :user_id], :unique => true
  end

  def self.down
    drop_table :event_spotter_roles
  end
end
