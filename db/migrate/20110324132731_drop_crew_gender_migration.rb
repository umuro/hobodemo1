class DropCrewGenderMigration < ActiveRecord::Migration
  def self.up
    remove_column :enrollments, :gender

    change_column :crews, :gender, :string, :limit => 255, :default => "Open"
  end

  def self.down
    add_column :enrollments, :gender, :string

    change_column :crews, :gender, :string, :default => "'--- :Open\n'"
  end
end
