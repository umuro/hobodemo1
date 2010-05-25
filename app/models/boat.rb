class Boat < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string, :required #PAUL name uniq? on which scope?
    sail_number :string, :required, :uniq
    timestamps
  end

  has_many :equipments
  has_many :equipment_types, :through=>:equipments
  belongs_to :boat_class

  has_many :fleet_memberships
  has_many :fleets, :through=>:fleet_memberships
  has_many :team_participations #has_one: one boat copy per partipication
  has_many :events, :through=>:team_participations
  #TODO define scope: missing equipment types. There is an equipment for each equipment_types
  #TODO define scope: skipper

  validates_presence_of :boat_class_id
  #TODO races is scope?
  def races
    fleets.*.race
  end

  def team_participation
    team_participations.first
  end


  # --- Permissions --- #

  def create_permitted?
    acting_user.any_organization_admin?
  end

  def update_permitted?
    acting_user.any_organization_admin?
  end

  def destroy_permitted?
    acting_user.any_organization_admin?
  end

  def view_permitted?(field)
    true
  end

end
