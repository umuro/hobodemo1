class RegistrationRoleMigration < ActiveRecord::Migration
  def self.up
    create_table :registration_roles do |t|
      t.string   :name, :null => false
      t.string   :operation, :null => false
      t.text     :external_markdown
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :event_id
    end
    add_index :registration_roles, [:name]
    add_index :registration_roles, [:event_id]

    create_table :registrations do |t|
      t.integer  :registration_role_id
      t.integer  :owner_id
      t.string   :state
      t.datetime :key_timestamp
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :registrations, [:registration_role_id]
    add_index :registrations, [:owner_id]
    add_index :registrations, [:state]

    add_column :enrollments, :registration_role_id, :integer
    remove_column :enrollments, :event_id

    remove_index :enrollments, :name => :index_enrollments_on_event_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_enrollments_on_boat_id_and_event_id rescue ActiveRecord::StatementInvalid
    add_index :enrollments, [:registration_role_id]
    add_index :enrollments, [:boat_id, :registration_role_id], :unique => true
  end

  def self.down
    remove_column :enrollments, :registration_role_id
    add_column :enrollments, :event_id, :integer

    drop_table :registration_roles
    drop_table :registrations

    remove_index :enrollments, :name => :index_enrollments_on_registration_role_id rescue ActiveRecord::StatementInvalid
    remove_index :enrollments, :name => :index_enrollments_on_boat_id_and_registration_role_id rescue ActiveRecord::StatementInvalid
    add_index :enrollments, [:event_id]
    add_index :enrollments, [:boat_id], :unique => true, :name => 'index_enrollments_on_boat_id_and_event_id'
  end
end
