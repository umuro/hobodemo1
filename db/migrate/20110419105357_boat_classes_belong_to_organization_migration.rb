class BoatClassesBelongToOrganizationMigration < ActiveRecord::Migration
  def self.up
    add_column :boat_classes, :organization_id, :integer
    add_index :boat_classes, [:organization_id]
  end

  def self.down
    remove_column :boat_classes, :organization_id
    remove_index :boat_classes, :name => :index_boat_classes_on_organization_id rescue ActiveRecord::StatementInvalid
  end
end
