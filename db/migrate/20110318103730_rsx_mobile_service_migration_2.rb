class RsxMobileServiceMigration2 < ActiveRecord::Migration
  def self.up
    remove_column :rsx_mobile_services, :touched

    change_column :crews, :gender, :string, :limit => 255, :default => :Open
  end

  def self.down
    add_column :rsx_mobile_services, :touched, :boolean, :default => false

    change_column :crews, :gender, :string, :default => "'--- :Open\n'"
  end
end
