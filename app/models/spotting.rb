class Spotting < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
	spotting_time :datetime
	timestamps
  end

  belongs_to :spot, :null=>false
  validates_presence_of :spot
  delegate :organization, :to=>:spot

  belongs_to :spotter, :class_name => "User", :null=>false, :creator=>true
  validates_presence_of :spotter
  def owner_is? u
    spotter_is? u
  end
  
  belongs_to :boat, :null=>false
  validates_presence_of :boat

  # --- Permissions --- #

  #FIXME post, put if user in group spotters
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
