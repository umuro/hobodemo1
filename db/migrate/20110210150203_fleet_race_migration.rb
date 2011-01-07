class FleetRaceMigration < ActiveRecord::Migration
  def self.up
    rename_table :fleets, :fleet_races
    rename_table :fleet_memberships, :fleet_race_memberships

    rename_column :fleet_race_memberships, :fleet_id, :fleet_race_id

    change_column :course_areas, :name, :string, :limit => 255, :null => false

    remove_column :races, :name
    remove_column :races, :course_area_id
    remove_column :races, :end_time
    remove_column :races, :status
    remove_column :races, :planned_time
    remove_column :races, :start_time
    change_column :races, :number, :integer, :null => false

    add_column :courses, :organization_id, :integer
    remove_column :courses, :race_id
    change_column :courses, :name, :string, :limit => 255, :null => false

    add_column :fleet_races, :status, :string
    add_column :fleet_races, :scheduled_time, :datetime
    add_column :fleet_races, :start_time, :datetime
    add_column :fleet_races, :end_time, :datetime
    add_column :fleet_races, :course_area_id, :integer
    add_column :fleet_races, :course_id, :integer
    change_column :fleet_races, :color, :string, :limit => 255, :null => false

    remove_index :user_profiles, :name => :index_people_on_user_id rescue ActiveRecord::StatementInvalid
    remove_index :user_profiles, :name => :index_people_on_country_id rescue ActiveRecord::StatementInvalid

    remove_index :fleet_race_memberships, :name => :index_fleet_memberships_on_fleet_id rescue ActiveRecord::StatementInvalid
    remove_index :fleet_race_memberships, :name => :index_fleet_memberships_on_boat_id rescue ActiveRecord::StatementInvalid
    add_index :fleet_race_memberships, [:fleet_race_id]
    add_index :fleet_race_memberships, [:boat_id]

    add_index :course_areas, [:name]

    remove_index :races, :name => :index_races_on_course_area_id rescue ActiveRecord::StatementInvalid
    add_index :races, [:number]

    remove_index :courses, :name => :index_courses_on_race_id rescue ActiveRecord::StatementInvalid
    add_index :courses, [:name]
    add_index :courses, [:organization_id]

    remove_index :enrollments, :name => :index_team_participations_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid

    remove_index :fleet_races, :name => :index_fleets_on_race_id rescue ActiveRecord::StatementInvalid
    add_index :fleet_races, [:color]
    add_index :fleet_races, [:race_id]
    add_index :fleet_races, [:course_area_id]
    add_index :fleet_races, [:course_id]
  end

  def self.down
    rename_column :fleet_race_memberships, :fleet_race_id, :fleet_id

    change_column :course_areas, :name, :string

    add_column :races, :name, :string
    add_column :races, :course_area_id, :integer
    add_column :races, :end_time, :datetime
    add_column :races, :status, :string
    add_column :races, :planned_time, :datetime
    add_column :races, :start_time, :datetime
    change_column :races, :number, :integer

    remove_column :courses, :organization_id
    add_column :courses, :race_id, :integer
    change_column :courses, :name, :string

    remove_column :fleet_races, :status
    remove_column :fleet_races, :scheduled_time
    remove_column :fleet_races, :start_time
    remove_column :fleet_races, :end_time
    remove_column :fleet_races, :course_area_id
    remove_column :fleet_races, :course_id
    change_column :fleets, :color, :string

    rename_table :fleet_races, :fleets
    rename_table :fleet_race_memberships, :fleet_memberships

    add_index :user_profiles, [:user_id], :name => 'index_people_on_user_id'
    add_index :user_profiles, [:country_id], :name => 'index_people_on_country_id'

    remove_index :fleet_memberships, :name => :index_fleet_race_memberships_on_fleet_race_id rescue ActiveRecord::StatementInvalid
    remove_index :fleet_memberships, :name => :index_fleet_race_memberships_on_boat_id rescue ActiveRecord::StatementInvalid
    add_index :fleet_memberships, [:fleet_id]
    add_index :fleet_memberships, [:boat_id]

    remove_index :course_areas, :name => :index_course_areas_on_name rescue ActiveRecord::StatementInvalid

    remove_index :races, :name => :index_races_on_number rescue ActiveRecord::StatementInvalid
    add_index :races, [:course_area_id]

    remove_index :courses, :name => :index_courses_on_name rescue ActiveRecord::StatementInvalid
    remove_index :courses, :name => :index_courses_on_organization_id rescue ActiveRecord::StatementInvalid
    add_index :courses, [:race_id]

    add_index :enrollments, [:event_id], :name => 'index_team_participations_on_event_id'
    add_index :enrollments, [:country_id], :name => 'index_team_participations_on_country_id'
    add_index :enrollments, [:boat_id], :name => 'index_team_participations_on_boat_id'
    add_index :enrollments, [:boat_id, :event_id], :unique => true, :name => 'index_team_participations_on_boat_id_and_event_id'

    remove_index :fleets, :name => :index_fleet_races_on_color rescue ActiveRecord::StatementInvalid
    remove_index :fleets, :name => :index_fleet_races_on_race_id rescue ActiveRecord::StatementInvalid
    remove_index :fleets, :name => :index_fleet_races_on_course_area_id rescue ActiveRecord::StatementInvalid
    remove_index :fleets, :name => :index_fleet_races_on_course_id rescue ActiveRecord::StatementInvalid
    add_index :fleets, [:race_id]
  end
end
