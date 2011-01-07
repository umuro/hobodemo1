class CrewMembership3Migration < ActiveRecord::Migration
  def self.up
    rename_column :crew_memberships, :crew_id, :joined_crew_id
    rename_column :crew_memberships, :invitor_id, :owner_id
    add_column :crew_memberships, :invitee_id, :integer
    remove_column :crew_memberships, :invitee_email

    rename_column :crews, :user_id, :owner_id

    rename_column :boats, :user_id, :owner_id

    remove_index :user_profiles, :name => :index_people_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :user_profiles, :name => :index_people_on_user_id rescue ActiveRecord::StatementInvalid

    remove_index :fleet_race_memberships, :name => :index_fleet_memberships_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :fleet_race_memberships, :name => :index_fleet_memberships_on_fleet_id rescue ActiveRecord::StatementInvalid

    remove_index :crew_memberships, :name => :index_crew_memberships_on_invitor_id rescue ActiveRecord::StatementInvalid
    remove_index :crew_memberships, :name => :index_crew_memberships_on_crew_id rescue ActiveRecord::StatementInvalid
    add_index :crew_memberships, [:joined_crew_id]
    add_index :crew_memberships, [:owner_id]
    add_index :crew_memberships, [:invitee_id]

    remove_index :flaggings, :name => :index_flaggings_on_race_id rescue ActiveRecord::StatementInvalid

    remove_index :events, :name => :index_events_on_name rescue ActiveRecord::StatementInvalid
    add_index :events, [:name]

    remove_index :enrollments, :name => :index_team_participations_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid

    remove_index :crews, :name => :index_crews_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :crews, [:owner_id]

    remove_index :fleet_races, :name => :index_fleets_on_race_id rescue ActiveRecord::StatementInvalid

    remove_index :boats, :name => :index_boats_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :boats, [:owner_id]
  end

  def self.down
    rename_column :crew_memberships, :joined_crew_id, :crew_id
    rename_column :crew_memberships, :owner_id, :invitor_id
    remove_column :crew_memberships, :invitee_id
    add_column :crew_memberships, :invitee_email, :string

    rename_column :crews, :owner_id, :user_id

    rename_column :boats, :owner_id, :user_id

    add_index :user_profiles, [:country_id], :name => 'index_people_on_country_id'
    add_index :user_profiles, [:user_id], :name => 'index_people_on_user_id'

    add_index :fleet_race_memberships, [:boat_id], :name => 'index_fleet_memberships_on_boat_id'
    add_index :fleet_race_memberships, [:fleet_race_id], :name => 'index_fleet_memberships_on_fleet_id'

    remove_index :crew_memberships, :name => :index_crew_memberships_on_joined_crew_id rescue ActiveRecord::StatementInvalid
    remove_index :crew_memberships, :name => :index_crew_memberships_on_owner_id rescue ActiveRecord::StatementInvalid
    remove_index :crew_memberships, :name => :index_crew_memberships_on_invitee_id rescue ActiveRecord::StatementInvalid
    add_index :crew_memberships, [:invitor_id]
    add_index :crew_memberships, [:crew_id]

    add_index :flaggings, [:fleet_race_id], :name => 'index_flaggings_on_race_id'

    remove_index :events, :name => :index_events_on_name rescue ActiveRecord::StatementInvalid
    add_index :events, [:name], :unique => true

    add_index :enrollments, [:country_id], :name => 'index_team_participations_on_country_id'
    add_index :enrollments, [:boat_id], :name => 'index_team_participations_on_boat_id'
    add_index :enrollments, [:event_id], :name => 'index_team_participations_on_event_id'
    add_index :enrollments, [:boat_id, :event_id], :unique => true, :name => 'index_team_participations_on_boat_id_and_event_id'

    remove_index :crews, :name => :index_crews_on_owner_id rescue ActiveRecord::StatementInvalid
    add_index :crews, [:user_id]

    add_index :fleet_races, [:race_id], :name => 'index_fleets_on_race_id'

    remove_index :boats, :name => :index_boats_on_owner_id rescue ActiveRecord::StatementInvalid
    add_index :boats, [:user_id]
  end
end
