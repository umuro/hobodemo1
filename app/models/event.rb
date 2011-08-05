class Event < ActiveRecord::Base
#FIXME rename class to Event

  hobo_model # Don't put anything above this

  EventType = HoboFields::EnumString.for( :Regatta, :RegattaSeries )

  fields do
    name :string, :required, :null=>false, :index=>true
#     event_type  Event::EventType, :required, :null=>false
    if_event_id  :string
    #TODO we are storing datetime in UTC. Beware in UI
    #FIXME daylight saving
    start_time  :datetime #UTC
    end_time    :datetime #UTC
    place       :string
    #TODO rich type for time zone
    time_zone   :time_zone
    description :text, :primary_content=>true
    site_url    :url_hyperlink
    registration_only :boolean
    timestamps
  end
  include EventLocalTime
  never_show  :registration_only
  
  set_default_order "updated_at DESC"

  belongs_to :event_folder, :null=>false
  validates_presence_of :event_folder
  validates_uniqueness_of :name, :scope=>:event_folder_id  
  delegate :organization, :to=>:event_folder
  
#  has_many :enrollments, 		:dependent=>:destroy
  has_many :registration_roles, 	:dependent=>:destroy
  has_many :enrollments, :through=>:registration_roles
  has_many :registrations, :through=>:registration_roles
  has_many :boats, :through=>:enrollments
  has_many :races, 			:dependent=>:destroy
  has_many :fleet_races, :through=>:races
  has_many :course_areas, 		:dependent=>:destroy
  has_many :calendar_entries, :dependent=>:destroy, :order=>'scheduled_time DESC'
  has_many :event_boat_classes, :dependent=>:destroy
  has_many :boat_classes, :through=>:event_boat_classes, :accessible=>true
  has_many :event_spotter_roles, :dependent=>:destroy
  has_many :event_spotters, :through=>:event_spotter_roles, 
           :source=>:user, :accessible=>true


#   has_many :news_items, :as => :news


  #active == not yet finished
  named_scope :active, 
      :conditions=>['end_time >= :current_time', 
                    { :current_time => Time.zone.now.utc}]

  before_save :store_defaults
  def store_defaults
    self.registration_only = self.registration_only
    true
  end
  protected :store_defaults
  
  def registration_only
      self[:registration_only].nil? && EVENT_CONFIG[:registration_only] or !!self[:registration_only]
  end

  def local_start_time
    start_time.in_time_zone( self.time_zone)
  end
  
  def local_end_time
    end_time.in_time_zone( self.time_zone )
  end
  
  # --- Permissions --- #

  def create_permitted?
     acting_user.is_owner_of? self
  end

  def update_permitted?
#     return false if any_changed? :start_time, :end_time
     acting_user.is_owner_of? self
  end

  def destroy_permitted?
     acting_user.is_owner_of? self
  end

  def view_permitted?(field)
    true
  end

end
