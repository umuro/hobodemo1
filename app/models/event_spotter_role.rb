class EventSpotterRole < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :event, :null=>false
  validates_presence_of :event
  
  belongs_to :user, :null=>false
  validates_presence_of :user
  
  delegate :organization, :to => :event

  
  index [:event_id, :user_id], :unique=>true
  
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
  
  def name
    user.label
  end

end