class Spot < ActiveRecord::Base

  hobo_model # Don't put anything above this
  SpotType = HoboFields::EnumString.for(:Report, :Finish, :OCS, :Mark)
  fields do
    name  :string
    position :integer
  spot_type  Spot::SpotType, :required
    timestamps
  end

  belongs_to :course
   #TODO implement and test the unique position assignment for special spots.
  #TODO What are you trying to do here?
#   def name
#     return "Spot #{n}" unless self[:spot]
#     self[:spot]
#   end



  validates_presence_of :course_id
  validates_uniqueness_of :position, :scope=>:course_id,  :allow_nil=>true

  # --- Callbacks --- #
  #FIXME default position is 1
  def before_validation_on_create
    if position.nil?
      write_attribute(:position, Spot.all.empty? ? 1 : Spot.maximum('position')+1) unless attribute?('position')
    end
  end
  
  # --- Methods ---- #
  def spotter_ready
  end
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
