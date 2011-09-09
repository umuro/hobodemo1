class Boat < ActiveRecord::Base

  hobo_model # Don't put anything above this

  set_search_columns :sail_number
  fields do
#    name        :string, :required #PAUL name uniq? on which scope?
    sail_number :string, :required, :name=>true, :index=>true, :null=>false
    timestamps
  end

  has_many :equipment,  :accessible => true, :dependent=>:destroy #BEWARE plural is equipment

  belongs_to :boat_class

#   has_many :fleet_race_memberships
#   has_many :fleet_races, :through=>:fleet_race_memberships
  has_many :enrollments #umur: yes, a boat can participate to many events
  
#   has_many :events, :through=>:enrollments
  
  #TODO define scope: missing equipment types. There is an equipment for each equipment_types
  #TODO define scope: skipper

  belongs_to :owner, :class_name => "User", :creator => true

  #GP: temporary remove
  validates_presence_of :boat_class_id
  #TODO races is scope?

#   def races
#     fleet_races.*.race
#   end

#   def to_s
#     "Boat[id: #{id}; name: #{name}; sail_number: #{sail_number}; user_id: #{user_id}]"
#   end

  def label
    "#{sail_number}(#{self.try(:boat_class)})"
  end

  def after_initialize
    self[:state] =:edit
  end
  def state; self[:state] = :edit; end
  def state=(v); self[:state]=v; end

  lifecycle do
    state :edit, :default=>true
    transition :edit_equipment, {:edit=>:edit},
	:params=>[:equipment],
	:available_to=>Proc.new { acting_user if acting_user.id == owner.id or acting_user.any_organization_admin? }
  end

  def ensure_equipment
    return unless boat_class
    e = self.equipment
    boat_class.equipment_types.each do |t|
      found = e.*.equipment_type.include? t
      created = Equipment.create!(:boat_id=>self.id, :serial=>"edit #{t}", :equipment_type=>t) unless found
    end
    t=self.try(:boat_class).try(:equipment_types)
    self.equipment.each do |e|
      e.destroy unless t.include? e.equipment_type
    end
    
  end
  # --- Permissions --- #

  def create_permitted?
    acting_user.is_owner_of? self
  end

  def update_permitted?
    acting_user.is_owner_of? self or acting_user.any_organization_admin?
  end

  def destroy_permitted?
    acting_user.is_owner_of? self
  end

  def view_permitted?(field)
    true
  end

end
