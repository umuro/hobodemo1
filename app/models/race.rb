class Race < ActiveRecord::Base

  hobo_model # Don't put anything above this

  Gender = HoboFields::EnumString.for(:Male, :Man, :M, :F, :Female, :W, :Woman, :O, :Open)

  fields do
    name        :string
    number       :integer
    status       :string
    planned_time :datetime
    start_time  :datetime
    end_time    :datetime
    gender Race::Gender, :required
    timestamps
    #PAUL stage, flight, match(xml attributes)
  end

  belongs_to :boat_class
  has_many :fleets
  belongs_to :event
  delegate :organization, :to=>:event

  belongs_to :course_area #FIXME belongs_to :course_area filter by event

  has_many :courses #FIXME has_one course but hobo

  validates_presence_of :boat_class_id
  validates_presence_of :course_area_id

  def default_fleet
      fleets.first
  end

  after_create :create_default_fleet

  def create_default_fleet
    raise 'no id on race' if id == 0
    Fleet.create(:race=>self)
  end

  named_scope :active,
      :conditions=>['end_time >= :current_time',
                    { :current_time => Time.zone.now.utc}]
  named_scope :today,
      :conditions=>['start_time <= :current_time AND end_time >= :current_time',
                    { :current_time => Time.zone.now.utc}]

  def course
    courses.first
  end

  def course_id
    course.id
  end

  def flags
    Flag.all
  end

  def boats
    b =[]
    fleets.each { |fleet|
      fleet.fleet_memberships.each{ |fm|
        b << fm.boat
      }
    }
    return b
  end
  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end
