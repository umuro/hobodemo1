class UseCaseSamples

  def self.build_fleet_race options={}
    Factory(:flag)

    defaults = {}
    defaults[:race]= options[:race] || Factory(:race) 
    defaults[:course]=options[:course] || UseCaseSamples.build_course(:organization=>defaults[:race].organization)
    
    Factory :fleet_race, options.reverse_merge(defaults)
  end

  def self.build_course options={}
    organization = options[:organization] || Factory(:organization)
    course = Factory(:course, :organization=>organization)

    spot_types = [:Report, :Finish, :OCS, :Mark, :Mark, :Mark]
    spot_types.each do |st| Factory(:spot, :course=>course, :spot_type=>st) end
    course
  end

  def self.build_boat options={}
    boat_class = Factory(:boat_class)
    (1..3).each do |i|
      Factory(:equipment_type, :boat_class_id=>boat_class.id)
    end

    owner = options[:owner]
    boat = Factory(:boat, :boat_class=>boat_class, :owner=>owner)
    boat_class.equipment_types.each do |et|
      Factory(:equipment, :equipment_type=>et, :boat=>boat)
    end
    return boat
  end

  def self.build_user_profile 
    u = Factory(:user)
    return Factory(:user_profile, :owner=>u)
  end

#   def self.enroll_to_event options={}
#     event = options[:event]
#     boat = options[:boat]
#     skipper = options[:skipper]
#     p = Factory(:enrollment, :event=>event, :boat=>boat) #FIXME Prove that boat cannot be reused by events
#   end

  def self.participate_to_fleet_race options={}
    boat = options[:boat]
    fleet_race = options[:fleet_race]
    user = options[:user] || Factory(:user)
    rr = Factory :registration_role, :event=>fleet_race.event
    
    boat.owner = user and boat.save! unless boat.owner

    e = Factory :enrollment, :registration_role=>rr, :boat=>boat, :owner=>boat.owner

    m = Factory :fleet_race_membership, :fleet_race=>fleet_race, :enrollment=>e

    e
  end
end