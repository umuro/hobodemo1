class EquipmentType < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string, :required, :null=>false
    description :text, :primary_content=>true
    timestamps
  end

  belongs_to :boat_class, :touch => true

  validates_presence_of :boat_class_id
  validates_uniqueness_of :name, :scope=>:boat_class_id

  # --- Permissions --- #

  def create_permitted?
    boat_class.creatable_by?(acting_user) if boat_class
  end

  def update_permitted?
    boat_class.updatable_by?(acting_user) if boat_class
  end

  def destroy_permitted?
    boat_class.destroyable_by?(acting_user) if boat_class
  end

  def view_permitted?(field)
    boat_class.viewable_by?(acting_user) if boat_class
  end

end