class EventBoatClass < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
  end

  belongs_to :event, :null=>false
  validates_presence_of :event
  belongs_to :boat_class, :null=>false
  validates_presence_of :boat_class

  delegate :organization, :to=>:event

  # --- Permissions --- #

  def create_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def update_permitted?
    acting_user.organization_admin?(  self.organization )
  end

  def destroy_permitted?
    acting_user.organization_admin?(  self.organization )
  end

  def view_permitted?(field)
    true
  end
end
