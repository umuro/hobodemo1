class EnrollmentMigration < ActiveRecord::Migration
  def self.up
    rename_table :team_participations, :enrollments

    remove_column :crew_members, :position
    remove_column :crew_members, :team_participation_id
    remove_column :crew_members, :remarks
    remove_column :crew_members, :person_id

    remove_index :crew_members, :name => :index_crew_members_on_team_participation_id rescue ActiveRecord::StatementInvalid
    remove_index :crew_members, :name => :index_crew_members_on_person_id rescue ActiveRecord::StatementInvalid

    remove_index :enrollments, :name => :index_team_participations_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid
    add_index :enrollments, [:boat_id, :event_id], :unique => true
    add_index :enrollments, [:event_id]
    add_index :enrollments, [:boat_id]
    add_index :enrollments, [:country_id]
  end

  def self.down
    add_column :crew_members, :position, :string, :null => false
    add_column :crew_members, :team_participation_id, :integer
    add_column :crew_members, :remarks, :text
    add_column :crew_members, :person_id, :integer

    rename_table :enrollments, :team_participations

    add_index :crew_members, [:team_participation_id]
    add_index :crew_members, [:person_id]

    remove_index :team_participations, :name => :index_enrollments_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid
    remove_index :team_participations, :name => :index_enrollments_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :team_participations, :name => :index_enrollments_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :team_participations, :name => :index_enrollments_on_country_id rescue ActiveRecord::StatementInvalid
    add_index :team_participations, [:event_id]
    add_index :team_participations, [:country_id]
    add_index :team_participations, [:boat_id]
    add_index :team_participations, [:boat_id, :event_id], :unique => true
  end
end
