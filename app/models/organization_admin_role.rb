class OrganizationAdminRole < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  belongs_to :organization, :null=>false
  belongs_to :user, :null=>false

  # --- Permissions --- #

  def create_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def update_permitted?
    acting_user.organization_admin?(  self.organization )
  end

  def destroy_permitted?
    acting_user.organization_admin?(  self.organization )
  end

  def view_permitted?(field)
    true
  end

end
