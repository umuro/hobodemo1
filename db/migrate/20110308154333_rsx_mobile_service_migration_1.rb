class RsxMobileServiceMigration1 < ActiveRecord::Migration
  def self.up
    create_table :rsx_mobile_services do |t|
      t.string   :api_key
      t.boolean  :touched, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :event_id
      t.string   :state
      t.datetime :key_timestamp
    end
    add_index :rsx_mobile_services, [:event_id]
    add_index :rsx_mobile_services, [:state]
  end

  def self.down
    drop_table :rsx_mobile_services
  end
end
