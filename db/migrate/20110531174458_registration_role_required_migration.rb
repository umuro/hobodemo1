class RegistrationRoleRequiredMigration < ActiveRecord::Migration
  def self.up
    change_column :enrollments, :registration_role_id, :integer, :null => false

    change_column :registrations, :registration_role_id, :integer, :null => false
  end

  def self.down
    change_column :enrollments, :registration_role_id, :integer

    change_column :registrations, :registration_role_id, :integer
  end
end
