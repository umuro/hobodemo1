class Organization < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string, :required, :unique, :null=>false, :index=>true
    timestamps
  end

  set_default_order "name ASC"

  has_many :event_folders, :dependent=>:destroy
  has_many :organization_admin_roles, :dependent=>:destroy
  has_many :organization_admins, :through=>:organization_admin_roles, 
           :source=>:user, :accessible=>true

  has_many :template_courses, :dependent=>:destroy
  has_many :courses, :dependent=>:destroy
                              
  has_many :boat_classes,     :dependent=>:destroy #boat_classes owned by organization
  
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
