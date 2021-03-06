class Race < ActiveRecord::Base

  hobo_model # Don't put anything above this

  Gender = HoboFields::EnumString.for(:Male, :Female,  :Open)

  fields do
#     name        :string
    number       :integer, :required, :name=>true, :index=>true, :null=>false
    gender Race::Gender, :required
    timestamps
    #PAUL stage, flight, match(xml attributes)
  end
  set_default_order "number ASC"

  belongs_to :event
  validates_presence_of :event
  validates_uniqueness_of :number, :scope=>:event_id
  validates_numericality_of :number, :greater_than=>0
  delegate :organization, :to=>:event
  
  belongs_to :boat_class
  
  has_many :fleet_races, 			:dependent=>:destroy
#   has_many :boats, :through=>:fleet_races

  validates_presence_of :boat_class_id

  def available_boat_classes
    if event.boat_classes.length > 0
      event.boat_classes
    else
      organization.boat_classes
    end
  end

  def available_enrollments
    return (event.enrollments - fleet_races.*.enrollments.flatten)
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
