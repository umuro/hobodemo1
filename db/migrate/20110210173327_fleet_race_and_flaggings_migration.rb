class FleetRaceAndFlaggingsMigration < ActiveRecord::Migration
  def self.up
    rename_column :flaggings, :race_id, :fleet_race_id

    remove_index :user_profiles, :name => :index_people_on_user_id rescue ActiveRecord::StatementInvalid
    remove_index :user_profiles, :name => :index_people_on_country_id rescue ActiveRecord::StatementInvalid

    remove_index :fleet_race_memberships, :name => :index_fleet_memberships_on_fleet_id rescue ActiveRecord::StatementInvalid
    remove_index :fleet_race_memberships, :name => :index_fleet_memberships_on_boat_id rescue ActiveRecord::StatementInvalid

    remove_index :flaggings, :name => :index_flaggings_on_race_id rescue ActiveRecord::StatementInvalid
    add_index :flaggings, [:fleet_race_id]

    remove_index :events, :name => :index_events_on_name rescue ActiveRecord::StatementInvalid
    add_index :events, [:name]

    remove_index :enrollments, :name => :index_team_participations_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid

    remove_index :fleet_races, :name => :index_fleets_on_race_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    rename_column :flaggings, :fleet_race_id, :race_id

    add_index :user_profiles, [:user_id], :name => 'index_people_on_user_id'
    add_index :user_profiles, [:country_id], :name => 'index_people_on_country_id'

    add_index :fleet_race_memberships, [:fleet_race_id], :name => 'index_fleet_memberships_on_fleet_id'
    add_index :fleet_race_memberships, [:boat_id], :name => 'index_fleet_memberships_on_boat_id'

    remove_index :flaggings, :name => :index_flaggings_on_fleet_race_id rescue ActiveRecord::StatementInvalid
    add_index :flaggings, [:race_id]

    remove_index :events, :name => :index_events_on_name rescue ActiveRecord::StatementInvalid
    add_index :events, [:name], :unique => true

    add_index :enrollments, [:event_id], :name => 'index_team_participations_on_event_id'
    add_index :enrollments, [:country_id], :name => 'index_team_participations_on_country_id'
    add_index :enrollments, [:boat_id], :name => 'index_team_participations_on_boat_id'
    add_index :enrollments, [:boat_id, :event_id], :unique => true, :name => 'index_team_participations_on_boat_id_and_event_id'

    add_index :fleet_races, [:race_id], :name => 'index_fleets_on_race_id'
  end
end
