class MissingEnrollmentIndexMigration < ActiveRecord::Migration
  def self.up
    add_index :enrollments, [:boat_id, :registration_role_id], :unique => true
  end

  def self.down
    remove_index :enrollments, :name => :index_enrollments_on_boat_id_and_registration_role_id rescue ActiveRecord::StatementInvalid
  end
end
