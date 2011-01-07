class Boat < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
#    name        :string, :required #PAUL name uniq? on which scope?
    sail_number :string, :required, :uniq, :name=>true, :index=>true, :null=>false
    timestamps
  end

  has_many :equipment
  
  belongs_to :boat_class, :touch => true

#   has_many :fleet_race_memberships
#   has_many :fleet_races, :through=>:fleet_race_memberships
  has_many :enrollments #has_one: one boat copy per partipication
  has_many :events, :through=>:enrollments
  #TODO define scope: missing equipment types. There is an equipment for each equipment_types
  #TODO define scope: skipper

  belongs_to :owner, :class_name => "User", :creator => true

  #GP: temporary remove
  #validates_presence_of :boat_class_id
  #TODO races is scope?

  def races
    fleet_races.*.race
  end

#   def to_s
#     "Boat[id: #{id}; name: #{name}; sail_number: #{sail_number}; user_id: #{user_id}]"
#   end

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
