class RegistrationOnlyMigration < ActiveRecord::Migration
  def self.up
    add_column :events, :registration_only, :boolean
  end

  def self.down
    remove_column :events, :registration_only
  end
end
