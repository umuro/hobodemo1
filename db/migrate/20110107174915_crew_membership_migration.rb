class CrewMembershipMigration < ActiveRecord::Migration
  def self.up
    rename_table :crew_members, :crew_memberships

    remove_index :user_profiles, :name => :index_people_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :user_profiles, :name => :index_people_on_user_id rescue ActiveRecord::StatementInvalid

    remove_index :enrollments, :name => :index_team_participations_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    rename_table :crew_memberships, :crew_members

    add_index :user_profiles, [:country_id], :name => 'index_people_on_country_id'
    add_index :user_profiles, [:user_id], :name => 'index_people_on_user_id'

    add_index :enrollments, [:country_id], :name => 'index_team_participations_on_country_id'
    add_index :enrollments, [:boat_id], :name => 'index_team_participations_on_boat_id'
    add_index :enrollments, [:event_id], :name => 'index_team_participations_on_event_id'
    add_index :enrollments, [:boat_id, :event_id], :unique => true, :name => 'index_team_participations_on_boat_id_and_event_id'
  end
end
