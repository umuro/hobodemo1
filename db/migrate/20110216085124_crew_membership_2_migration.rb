class CrewMembership2Migration < ActiveRecord::Migration
  def self.up
    create_table :crews do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
    end
    add_index :crews, [:user_id]

    add_column :crew_memberships, :invitee_email, :string
    add_column :crew_memberships, :crew_id, :integer
    add_column :crew_memberships, :invitor_id, :integer
    add_column :crew_memberships, :state, :string
    add_column :crew_memberships, :key_timestamp, :datetime

    change_column :users, :state, :string, :limit => 255, :default => "inactive"

    remove_index :user_profiles, :name => :index_people_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :user_profiles, :name => :index_people_on_user_id rescue ActiveRecord::StatementInvalid

    add_index :crew_memberships, [:crew_id]
    add_index :crew_memberships, [:invitor_id]
    add_index :crew_memberships, [:state]

    remove_index :enrollments, :name => :index_team_participations_on_country_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_team_participations_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    remove_column :crew_memberships, :invitee_email
    remove_column :crew_memberships, :crew_id
    remove_column :crew_memberships, :invitor_id
    remove_column :crew_memberships, :state
    remove_column :crew_memberships, :key_timestamp

    change_column :users, :state, :string, :default => "active"

    drop_table :crews

    add_index :user_profiles, [:country_id], :name => 'index_people_on_country_id'
    add_index :user_profiles, [:user_id], :name => 'index_people_on_user_id'

    remove_index :crew_memberships, :name => :index_crew_memberships_on_crew_id rescue ActiveRecord::StatementInvalid
    remove_index :crew_memberships, :name => :index_crew_memberships_on_invitor_id rescue ActiveRecord::StatementInvalid
    remove_index :crew_memberships, :name => :index_crew_memberships_on_state rescue ActiveRecord::StatementInvalid

    add_index :enrollments, [:country_id], :name => 'index_team_participations_on_country_id'
    add_index :enrollments, [:boat_id], :name => 'index_team_participations_on_boat_id'
    add_index :enrollments, [:event_id], :name => 'index_team_participations_on_event_id'
    add_index :enrollments, [:boat_id, :event_id], :unique => true, :name => 'index_team_participations_on_boat_id_and_event_id'
  end
end
