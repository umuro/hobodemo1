class OrganizationAdminRole < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :organization, :null=>false
  validates_presence_of :organization
  
  belongs_to :user, :null=>false
  validates_presence_of :user

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
