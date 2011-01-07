class Spot < ActiveRecord::Base

  hobo_model # Don't put anything above this

  SpotType = HoboFields::EnumString.for(:Report, :Finish, :OCS, :Mark)

  fields do
#     name  :string #Calculated below
    position :integer
    spot_type Spot::SpotType, :required
    timestamps
  end

  def name
    return "#{spot_type} #{position}" if position
    "#{spot_type}"
  end
  
  belongs_to :course
  has_many :spottings, :dependent=>:destroy

  delegate :organization, :to=>:course

  validates_presence_of :course
  validates_uniqueness_of :position, :scope=>:course_id, :allow_nil=>true

  def initialize(attrs={}, &block)
    super
  end
  # --- Callbacks --- #

  def course_id= i
    self[:course_id] = i
    set_default_position
  end
  
  def course= c
    self[:course_id] = c && c.id
    set_default_position
  end
  
  def spot_type= t
    self[:spot_type] = t
    set_default_position
  end

  def set_default_position
    return unless new_record?
    position = nil and return unless spot_type == :Mark
    return unless position.nil?
    return unless course
    
    top = Spot.maximum('position', :conditions=>{:course_id=>course.id}) || 0
    m = top + 1
    self[:position]= m unless attribute?('position')
  end

  def after_initialize
    set_default_position
  end
  
  
  # --- Methods ---- #

  def spotter_ready
    true
  end

  # --- Permissions --- #

  def create_permitted?
    course.creatable_by?(acting_user) if course
  end

  def update_permitted?
    false
  end

  def destroy_permitted?
    course.destroyable_by?(acting_user) if course
  end

  def view_permitted?(field)
    true
  end

end