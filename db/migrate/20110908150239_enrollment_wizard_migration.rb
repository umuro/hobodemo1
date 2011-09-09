class EnrollmentWizardMigration < ActiveRecord::Migration
  def self.up
    create_table :enrollment_wizards do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :owner_id
      t.integer  :registration_role_id
      t.integer  :enrollment_id
      t.integer  :applicant_id
      t.integer  :boat_id
      t.integer  :crew_id
      t.integer  :country_id
      t.string   :state, :default => nil

      t.datetime :key_timestamp
    end
    add_index :enrollment_wizards, [:owner_id]
#     add_index :enrollment_wizards, [:registration_role_id]
#     add_index :enrollment_wizards, [:applicant_id]
#     add_index :enrollment_wizards, [:boat_id]
    add_index :enrollment_wizards, [:state]
  end

  def self.down

    drop_table :enrollment_wizards

  end
end
