class Flagging < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    flagging_time :datetime
    timestamps
  end
  
  belongs_to :fleet_race
  validates_presence_of :fleet_race
  delegate :organization, :to=>:fleet_race

  belongs_to :spotter, :class_name => "User", :creator=>true
  validates_presence_of :spotter
  def owner_is? u
    spotter_is? u
  end

  belongs_to :flag
  validates_presence_of :flag


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
