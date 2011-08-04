class AddFleetRaceCopyFrom < ActiveRecord::Migration
  def self.up
    add_column :fleet_races, :copy_assignments_from_id, :integer
  end

  def self.down
    remove_column :fleet_races, :copy_assignments_from_id
  end
end
