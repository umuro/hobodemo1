class Course < ActiveRecord::Base

  hobo_model # Don't put anything above this
  #TODO remove editor of belongs_to :race. It is master or not. Not changeable.

  fields do
    name :string, :required, :null=>false, :index=>true
    timestamps
  end

#   belongs_to :fleet_race #this is master if race is null
  belongs_to :organization
  validates_presence_of :organization
  validates_uniqueness_of :name, :scope=>:organization_id, :if=>:organization
  
  has_many :fleet_races, 		:dependent=>:nullify
  has_many :spots, 			:dependent=>:destroy

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

  def clone_with_spots
    new_course = self.clone
    new_course.organization_id = nil
    new_course.save(false)

    new_spots = self.spots.*.clone
    new_spots.*.course_id = new_course.id
    new_spots.*.save(false)

    new_course
  end
end