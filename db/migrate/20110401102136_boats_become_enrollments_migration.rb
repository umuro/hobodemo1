class BoatsBecomeEnrollmentsMigration < ActiveRecord::Migration
  def self.up
    FleetRaceMembership.delete_all if defined? FleetRaceMembership
    add_column :fleet_race_memberships, :enrollment_id, :integer
    remove_column :fleet_race_memberships, :boat_id

    remove_index :fleet_race_memberships, :name => :index_fleet_race_memberships_on_boat_id rescue ActiveRecord::StatementInvalid
    add_index :fleet_race_memberships, [:enrollment_id]
  end

  def self.down
    remove_column :fleet_race_memberships, :enrollment_id
    add_column :fleet_race_memberships, :boat_id, :integer, :null => false

    remove_index :fleet_race_memberships, :name => :index_fleet_race_memberships_on_enrollment_id rescue ActiveRecord::StatementInvalid
    add_index :fleet_race_memberships, [:boat_id]
  end
end
