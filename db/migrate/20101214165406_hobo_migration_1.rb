class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string   :name
      t.string   :code
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :flags do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :name, :null => false
    end

    create_table :organizations do |t|
      t.string   :name, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :organizations, [:name], :unique => true

    create_table :boat_classes do |t|
      t.string   :name, :null => false
      t.text     :description
      t.integer  :no_of_crew_members, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :news_items do |t|
      t.string   :title
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :news_id
      t.string   :news_type
    end
    add_index :news_items, [:news_type, :news_id]

    create_table :team_participations do |t|
      t.date     :date_entered
      t.date     :date_measured
      t.boolean  :measured_passed?, :default => false
      t.boolean  :insured?, :default => false
      t.boolean  :paid?, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :description
      t.string   :team_rid
      t.string   :gender
      t.integer  :event_id
      t.integer  :boat_id
      t.integer  :country_id
    end
    add_index :team_participations, [:boat_id, :event_id], :unique => true
    add_index :team_participations, [:event_id]
    add_index :team_participations, [:boat_id]
    add_index :team_participations, [:country_id]

    create_table :course_areas do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :event_id
    end
    add_index :course_areas, [:event_id]

    create_table :races do |t|
      t.string   :name
      t.integer  :number
      t.string   :status
      t.datetime :planned_time
      t.datetime :start_time
      t.datetime :end_time
      t.string   :gender
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :boat_class_id
      t.integer  :event_id
      t.integer  :course_area_id
    end
    add_index :races, [:boat_class_id]
    add_index :races, [:event_id]
    add_index :races, [:course_area_id]

    create_table :spottings do |t|
      t.datetime :spotting_time
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :spotter_id, :null => false
      t.integer  :spot_id, :null => false
      t.integer  :boat_id, :null => false
    end
    add_index :spottings, [:spotter_id]
    add_index :spottings, [:spot_id]
    add_index :spottings, [:boat_id]

    create_table :flaggings do |t|
      t.datetime :flagging_time
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :spotter_id
      t.integer  :flag_id
      t.integer  :race_id
    end
    add_index :flaggings, [:spotter_id]
    add_index :flaggings, [:flag_id]
    add_index :flaggings, [:race_id]

    create_table :courses do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :race_id
    end
    add_index :courses, [:race_id]

    create_table :crew_members do |t|
      t.string   :position, :null => false
      t.text     :remarks
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :team_participation_id
      t.integer  :person_id
    end
    add_index :crew_members, [:team_participation_id]
    add_index :crew_members, [:person_id]

    create_table :fleet_memberships do |t|
      t.integer :fleet_id
      t.integer :boat_id
    end
    add_index :fleet_memberships, [:fleet_id]
    add_index :fleet_memberships, [:boat_id]

    create_table :fleets do |t|
      t.string   :color
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :race_id
    end
    add_index :fleets, [:race_id]

    create_table :organization_admin_roles do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id, :null => false
      t.integer  :user_id, :null => false
    end
    add_index :organization_admin_roles, [:organization_id]
    add_index :organization_admin_roles, [:user_id]

    create_table :events do |t|
      t.string   :name, :null => false
      t.string   :event_type, :null => false
      t.string   :if_event_id
      t.datetime :start_time
      t.datetime :end_time
      t.string   :time_zone
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :event_series_id, :null => false
    end
    add_index :events, [:name], :unique => true
    add_index :events, [:event_series_id]

    create_table :spots do |t|
      t.string   :name
      t.integer  :position
      t.string   :spot_type
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :course_id
    end
    add_index :spots, [:course_id]

    create_table :event_series do |t|
      t.string   :name, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :organization_id, :null => false
    end
    add_index :event_series, [:name], :unique => true
    add_index :event_series, [:organization_id]

    create_table :equipment do |t|
      t.string   :serial, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :boat_id
      t.integer  :equipment_type_id
    end
    add_index :equipment, [:boat_id]
    add_index :equipment, [:equipment_type_id]

    create_table :people do |t|
      t.string   :first_name
      t.string   :middle_name
      t.string   :last_name
      t.string   :gender
      t.string   :if_person_id
      t.date     :birthdate
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :country_id
    end
    add_index :people, [:user_id]
    add_index :people, [:country_id]

    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :email_address
      t.boolean  :administrator, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :state, :default => "active"
      t.datetime :key_timestamp
    end
    add_index :users, [:state]

    create_table :boats do |t|
      t.string   :name
      t.string   :sail_number
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :boat_class_id
    end
    add_index :boats, [:boat_class_id]

    create_table :equipment_types do |t|
      t.string   :name, :null => false
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :boat_class_id
    end
    add_index :equipment_types, [:boat_class_id]
  end

  def self.down
    drop_table :countries
    drop_table :flags
    drop_table :organizations
    drop_table :boat_classes
    drop_table :news_items
    drop_table :team_participations
    drop_table :course_areas
    drop_table :races
    drop_table :spottings
    drop_table :flaggings
    drop_table :courses
    drop_table :crew_members
    drop_table :fleet_memberships
    drop_table :fleets
    drop_table :organization_admin_roles
    drop_table :events
    drop_table :spots
    drop_table :event_series
    drop_table :equipment
    drop_table :people
    drop_table :users
    drop_table :boats
    drop_table :equipment_types
  end
end
