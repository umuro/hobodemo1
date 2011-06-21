class FleetRace < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    color           :string, :required, :name=>true, :index=>true, :null=>false
    status          :string
    scheduled_time  :datetime
    start_time      :datetime
    end_time        :datetime
    timestamps
  end

  set_default_order "color ASC"

  delegate :organization, :to=>:race
  delegate :event, :to=>:race
  delegate :event_id, :to=>:race
  delegate :number, :to=>:race

  has_many :fleet_race_memberships, :dependent=>:destroy
  has_many :enrollments, :through=>:fleet_race_memberships
  has_many :flaggings, 					:dependent=>:destroy
  
  belongs_to :race
  belongs_to :course_area, :conditions =>'event_id = #{event_id}'
  belongs_to :course, :conditions=> 'organization_id = #{organization.id}', :dependent=>:destroy

  validates_presence_of :course, :unless=> lambda {|r| r.new_record?}
  validates_presence_of :course_area_id
  validates_presence_of :race
  validates_uniqueness_of :color, :scope=>:race_id
  
  after_user_new { |r|
      r[:scheduled_time] = r.event && r.event.start_time &&
                             r.event.start_time > Time.zone.now.in_time_zone(r.event.time_zone) ?
                             r.event.start_time : Time.zone.now if r.new_record?
  }
  
  named_scope :active, :conditions => {:end_time => nil}
      
  named_scope :today_for, lambda { |object_with_time_zone|
    now = Time.zone.now
    { :conditions => ['scheduled_time >= :low_time AND scheduled_time < :high_time',
                      {:low_time => now.in_time_zone(object_with_time_zone.time_zone).at_beginning_of_day,
                       :high_time => now.in_time_zone(object_with_time_zone.time_zone).tomorrow.at_midnight}]
    }
  }

  def flags
    Flag.all
  end

  def boats
    enrollments.*.boat
  end

  def course_area
    CourseArea.find_by_id course_area_id #Override belongs_to_condition
  end

  def course
    Course.find_by_id course_id #Override belongs_to_condition
  end

  # --- Permissions --- #

  
  def create_permitted?
#    return true if acting_user.administrator?
    return false if any_changed? :start_time, :end_time, :status
    acting_user.is_owner_of? self
  end

  def update_permitted?
#    return true if acting_user.administrator?
    before_race = scheduled_time.nil? || scheduled_time.utc > DateTime.now.utc
    return false if before_race && (any_changed? :start_time, :end_time, :status)
    acting_user.is_owner_of? self
  end

  def destroy_permitted?
    acting_user.is_owner_of? self
  end
  
  def view_permitted?(field)
    true
  end

  def short_label
    return "#{race.boat_class.name} - #{number} #{color}"
  end

  def label
    short_label
  end

  before_save lambda { |fr|

    if fr.update_with_hobo_permission_check

      if fr.course_id != fr.course_id_was
        fr.course = fr.course.clone_with_spots if fr.course_id
        Course.find(fr.course_id_was).destroy if fr.course_id_was
      end
    end
  }

  # after_destroy lambda { |record| record.course.destroy }

end
