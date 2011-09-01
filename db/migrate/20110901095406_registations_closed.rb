class RegistationsClosed < ActiveRecord::Migration
  def self.up
    add_column :events, :registrations_closed, :boolean
  end

  def self.down
    remove_column :events, :registrations_closed
  end
end
