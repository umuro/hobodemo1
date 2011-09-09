class BoatClass < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name               :string, :required, :unique, :null=>false
    description        :text, :primary_content=>true
    no_of_crew_members :integer, :required, :null=>false
    timestamps
  end

  has_many :boats, :dependent=>:nullify
  has_many :equipment_types,  :accessible => true, :dependent=>:destroy

  belongs_to :organization #boat_classes owned by organization

  def label
    "#{name}(#{self.try(:organization)})"
  end

  def after_initialize
    self[:state] =:edit
  end
  def state; self[:state] = :edit; end
  def state=(v); self[:state]=v; end

  lifecycle do
    state :edit, :default=>true
    transition :edit_equipment_type, {:edit=>:edit},
	:params=>[:equipment_types],
	:available_to=>Proc.new { organization.organization_admins }
  end
  
  # --- Permissions --- #

  def create_permitted?
    acting_user.is_owner_of? self
  end

  def update_permitted?
    acting_user.is_owner_of? self
  end

  def destroy_permitted?
    acting_user.is_owner_of? self
  end

  def view_permitted?(field)
    true
  end

end