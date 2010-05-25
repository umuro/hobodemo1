class Spotting < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
	spotting_time :datetime
	timestamps
  end

  belongs_to :spotter, :class_name => "User", :null=>false
  belongs_to :spot, :null=>false
  belongs_to :boat, :null=>false
#   belongs_to :race

  validates_presence_of :spotter_id
  validates_presence_of :spot_id
  validates_presence_of :boat_id
  # --- Permissions --- #

  #FIXME post, put if user in group spotters
  def create_permitted?
#     debugger
    acting_user.signed_up?
  end

  def update_permitted?
    debugger
    acting_user.signed_up?
  end

  def destroy_permitted?
#     debugger
    acting_user.signed_up?
  end

  def view_permitted?(field)
    true
  end

end
