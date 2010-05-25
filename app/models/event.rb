class Event < ActiveRecord::Base
#FIXME rename class to Event

  hobo_model # Don't put anything above this

  EventType = HoboFields::EnumString.for( :Regatta, :RegattaSeries )

  fields do
    name :string, :required, :unique, :null=>false, :index=>true
    event_type  Event::EventType, :required, :null=>false
    if_event_id  :string
    #TODO we are storing datetime in UTC. Beware in UI
    #FIXME daylight saving
    start_time  :datetime #UTC
    end_time    :datetime #UTC
    place       :string
    #TODO rich type for time zone
    time_zone   :string
    description :text, :primary_content=>true
    timestamps
  end

  belongs_to :event_series, :null=>false
  delegate :organization, :to=>:event_series
  
  has_many :team_participations
  has_many :boats, :through=>:team_participations
  has_many :races
  has_many :course_areas

#   has_many :news_items, :as => :news

  validates_uniqueness_of :name, :scope=>:start_time

  #active == not yet finished
  named_scope :active, 
      :conditions=>['end_time >= :current_time', 
                    { :current_time => Time.zone.now.utc}]
  # --- Permissions --- #

  def create_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def update_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def destroy_permitted?
    acting_user.organization_admin?( self.organization )
  end

  def view_permitted?(field)
    true
  end

end
