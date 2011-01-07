class DropOwnerFromCrewMembershipAndAddTypeToCrews < ActiveRecord::Migration
  def self.up
    remove_column :crew_memberships, :owner_id

    add_column :crews, :crew_type, :string, :default => "Group"

    remove_index :crew_memberships, :name => :index_crew_memberships_on_owner_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :crew_memberships, :owner_id, :integer

    remove_column :crews, :crew_type

    add_index :crew_memberships, [:owner_id]
  end
end
