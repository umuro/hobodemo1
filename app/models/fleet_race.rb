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
  include EventLocalTime

  set_default_order "race_id ASC,color ASC"

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
  belongs_to :copy_assignments_from, :class_name=>'FleetRace', :conditions=> '#{other_races_condition}'

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
    now = Time.now
    { :conditions => ['scheduled_time >= :low_time AND scheduled_time < :high_time',
                      {:low_time => now.in_time_zone(object_with_time_zone.event_tz).at_beginning_of_day.utc,
                       :high_time => now.in_time_zone(object_with_time_zone.event_tz).tomorrow.at_midnight.utc}]
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

  def other_races_condition
    other_races = event.races-[self.race]
    if other_races.empty?
      '1=2' # dummy false condition to return nil
    else
      "race_id <> #{race_id} and race_id in (#{other_races.*.id.join(',')})"
    end
  end

  # --- Permissions --- #

  
  def create_permitted?
    return false if any_changed? :start_time, :end_time, :status
    acting_user.is_owner_of? self
  end

  def update_permitted?
    # NOTE: It appears that if scheduled_time is called directly, the field disappears with update_permitted. So it has
    # been changed to use hash notation.
    before_race = self[:scheduled_time].nil? || self[:scheduled_time].utc > DateTime.now.utc
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

  def to_s
    "race #{race.number} - #{color}"
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
