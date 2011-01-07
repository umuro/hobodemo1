class CrewDefaultGenderMigration < ActiveRecord::Migration
  def self.up
    add_column :enrollments, :state, :string
    add_column :enrollments, :key_timestamp, :datetime

    change_column :crews, :gender, :string, :limit => 255, :default => :Open

    add_index :enrollments, [:state]
  end

  def self.down
    remove_column :enrollments, :state
    remove_column :enrollments, :key_timestamp

    change_column :crews, :gender, :string, :default => "'--- :Open\n'"

    remove_index :enrollments, :name => :index_enrollments_on_state rescue ActiveRecord::StatementInvalid
  end
end
