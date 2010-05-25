class EquipmentType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string, :required, :null=>false
    description :text, :primary_content=>true
    timestamps
  end

  belongs_to :boat_class
#   has_many :equipments
#   has_many :boats, :through=>:equipments

  validates_presence_of :boat_class_id
  validates_uniqueness_of :name, :scope=>:boat_class_id
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
