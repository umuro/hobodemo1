class SpotsDropNameMigration < ActiveRecord::Migration
  def self.up
    remove_column :spots, :name
  end

  def self.down
    add_column :spots, :name, :string
  end
end
