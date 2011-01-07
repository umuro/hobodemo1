class CourseArea < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string, :required, :null=>false, :index=>true
    timestamps
  end

  belongs_to :event
  validates_presence_of :event
  validates_uniqueness_of :name, :scope=>:event_id
  validates_presence_of :name
  delegate :organization, :to=>:event

  has_many :fleet_races #dependent=>see destroy

  def destoy
    super if fleet_races.empty?
  end
  
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
