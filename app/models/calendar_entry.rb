class CalendarEntry < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name           :string, :required, :null=>false
    scheduled_time :datetime
    timestamps
  end

  set_default_order "scheduled_time DESC"
  
  belongs_to :event, :null=>false
  validates_presence_of :event
  validates_uniqueness_of :name, :scope=>:event_id
  delegate :organization, :to=>:event

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

  def short_label
    self.name
  end

  def label
    short_label + ' ('+scheduled_time.to_s+')'
  end
  
end
