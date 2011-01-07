class EnrollmentPreCleanupMigration < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :owner_id, :integer
    remove_column :user_profiles, :user_id

    add_column :enrollments, :date_measured, :date
    add_column :enrollments, :measured, :boolean, :default => false
    add_column :enrollments, :insured, :boolean, :default => false
    add_column :enrollments, :paid, :boolean, :default => false
    add_column :enrollments, :owner_id, :integer
    add_column :enrollments, :crew_id, :integer
    remove_column :enrollments, :date_entered

    add_column :crews, :gender, :string, :default => :Open

    remove_column :boats, :name
    change_column :boats, :sail_number, :string, :limit => 255, :null => false

    remove_index :user_profiles, :name => :index_user_profiles_on_user_id rescue ActiveRecord::StatementInvalid
    add_index :user_profiles, [:owner_id]

    remove_index :event_folders, :name => :index_event_series_on_organization_id rescue ActiveRecord::StatementInvalid
    remove_index :event_folders, :name => :index_event_series_on_name rescue ActiveRecord::StatementInvalid

    add_index :enrollments, [:owner_id]
    add_index :enrollments, [:crew_id]

    add_index :boats, [:sail_number]
  end

  def self.down
    remove_column :user_profiles, :owner_id
    add_column :user_profiles, :user_id, :integer

    remove_column :enrollments, :date_measured
    remove_column :enrollments, :measured
    remove_column :enrollments, :insured
    remove_column :enrollments, :paid
    remove_column :enrollments, :owner_id
    remove_column :enrollments, :crew_id
    add_column :enrollments, :date_entered, :date

    remove_column :crews, :gender

    add_column :boats, :name, :string
    change_column :boats, :sail_number, :string

    remove_index :user_profiles, :name => :index_user_profiles_on_owner_id rescue ActiveRecord::StatementInvalid
    add_index :user_profiles, [:user_id]

    add_index :event_folders, [:organization_id], :name => 'index_event_series_on_organization_id'
    add_index :event_folders, [:name], :unique => true, :name => 'index_event_series_on_name'

    remove_index :enrollments, :name => :index_enrollments_on_owner_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_enrollments_on_crew_id rescue ActiveRecord::StatementInvalid

    remove_index :boats, :name => :index_boats_on_sail_number rescue ActiveRecord::StatementInvalid
  end
end
