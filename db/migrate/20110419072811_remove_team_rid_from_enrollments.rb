class RemoveTeamRidFromEnrollments < ActiveRecord::Migration
  def self.up
    remove_column :enrollments, :team_rid

    change_column :calendar_entries, :name, :string, :limit => 255, :null => false
  end

  def self.down
    add_column :enrollments, :team_rid, :string

    change_column :calendar_entries, :name, :string
  end
end
