class Equipment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    serial :string, :required, :name=>true, :null=>false
    timestamps
  end

  belongs_to :boat
  belongs_to :equipment_type

  validates_presence_of :boat_id
  validates_presence_of :equipment_type_id
  validates_uniqueness_of :serial, :scope=>:equipment_type_id
  # --- Permissions --- #

  def create_permitted?
    acting_user.any_organization_admin?
  end

  def update_permitted?
    acting_user.any_organization_admin?
  end

  def destroy_permitted?
    acting_user.any_organization_admin?
  end

  def view_permitted?(field)
    true
  end

end
