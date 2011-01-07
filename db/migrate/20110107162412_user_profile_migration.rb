class UserProfileMigration < ActiveRecord::Migration
  def self.up
    rename_table :people, :user_profiles

    remove_index :user_profiles, :name => :index_people_on_user_id rescue ActiveRecord::StatementInvalid
    remove_index :user_profiles, :name => :index_people_on_country_id rescue ActiveRecord::StatementInvalid
    add_index :user_profiles, [:user_id]
    add_index :user_profiles, [:country_id]

    remove_index :enrollments, :name => :index_team_participations_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    rename_table :user_profiles, :people

    remove_index :people, :name => :index_user_profiles_on_user_id rescue ActiveRecord::StatementInvalid
    remove_index :people, :name => :index_user_profiles_on_country_id rescue ActiveRecord::StatementInvalid
    add_index :people, [:user_id]
    add_index :people, [:country_id]

    add_index :enrollments, [:event_id], :name => 'index_team_participations_on_event_id'
    add_index :enrollments, [:country_id], :name => 'index_team_participations_on_country_id'
    add_index :enrollments, [:boat_id], :name => 'index_team_participations_on_boat_id'
    add_index :enrollments, [:boat_id, :event_id], :unique => true, :name => 'index_team_participations_on_boat_id_and_event_id'
  end
end
