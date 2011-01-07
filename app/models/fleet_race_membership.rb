class FleetRaceMembership < ActiveRecord::Base
  hobo_model # Don't put anything above this

  fields do
  end

  belongs_to :fleet_race, :null=>false
  validates_presence_of :fleet_race
  delegate :organization, :to=>:fleet_race
  delegate :event, :to=>:fleet_race
  
  belongs_to :enrollment
  validates_presence_of :enrollment
  
  # In memory update for rsx mobile service
  initiate_update_trigger :recipient => :event, :scenario => :rsx_mobile_service

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
