class Equipment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    serial :string, :required, :name=>true, :null=>false
    timestamps
  end

  belongs_to :boat, :touch => true

  belongs_to :equipment_type, :conditions => 'boat_class_id = #{self.boat.boat_class_id}' #, :touch => true

  validates_presence_of :boat_id
  validates_presence_of :equipment_type_id
  validates_uniqueness_of :serial, :scope=>:equipment_type_id

  # --- Permissions --- #

  def create_permitted?
    boat.creatable_by?(acting_user) if boat
  end

  def update_permitted?
    boat.updatable_by?(acting_user) if boat
  end

  def destroy_permitted?
    boat.destroyable_by?(acting_user) if boat
  end

  def view_permitted?(field)
    boat.viewable_by?(acting_user) if boat
  end
  
  def label
    "#{equipment_type.to_s} - #{boat.sail_number} (#{serial})"
  end

end
