class Organization < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string, :required, :unique, :null=>false, :index=>true
    timestamps
  end

  has_many :event_series

  has_many :organization_admin_roles, :dependent=>:destroy
  has_many :organization_admins, :through=>:organization_admin_roles, :source=>:user, :accessible=>true
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.organization_admin?( self )
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
