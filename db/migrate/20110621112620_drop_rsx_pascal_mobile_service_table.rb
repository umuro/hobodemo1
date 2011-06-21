class DropRsxPascalMobileServiceTable < ActiveRecord::Migration
  def self.up
    drop_table :rsx_mobile_services
  end

  def self.down
    create_table "rsx_mobile_services", :force => true do |t|
      t.string   "api_key"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "event_id"
      t.string   "state"
      t.datetime "key_timestamp"
    end

    add_index "rsx_mobile_services", ["event_id"], :name => "index_rsx_mobile_services_on_event_id"
    add_index "rsx_mobile_services", ["state"], :name => "index_rsx_mobile_services_on_state"
  end
end
