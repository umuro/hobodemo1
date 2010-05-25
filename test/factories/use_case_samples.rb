class UseCaseSamples
  def self.build_boat 
    boat_class = Factory(:boat_class)
    (1..3).each do |i|
      Factory(:equipment_type, :boat_class_id=>boat_class.id)
    end

    boat = Factory(:boat, :boat_class=>boat_class)
    boat_class.equipment_types.each do |et|
      Factory(:equipment, :equipment_type=>et, :boat=>boat)
    end
    return boat
  end

  def self.build_race 
    Factory(:flag) #FIXME "See race.rb; Flags are global temporarily"
    event = Factory(:event)
#     race = Factory(:race,  :boat_class=>BoatClass.first)
    #TODO For an unknown reason we cannot use default event
    race = Factory(:race, :event=>event, :boat_class=>BoatClass.first)
    build_master_course race
    return race
  end

  def self.build_person 
  u = Factory(:user)
    return Factory(:person, :user=>u)
  end

  def self.participate_to_event options={}
    event = options[:event]
    boat = options[:boat]
    skipper = options[:skipper]
    crew_members = options[:crew_members]
    crew_members ||= []

    p = Factory(:team_participation, :event=>event, :boat=>boat) #FIXME Prove that boat cannot be reused by events

    Factory(:crew_member, :team_participation=>p, :person=>skipper, :position=>:S)

    crew_members.each do | person |
      Factory(:crew_member, :team_participation=>p, :person=>person)
    end
  end

  def self.participate_to_race_fleet options={}
    boat = options[:boat]
    race = options[:race]
#     test.assert_not_nil race.default_fleet
    race.default_fleet.boats << boat
    race.default_fleet.save!
  end

  def self.build_master_course race=nil
     course = Factory(:course, :race=>race)
    (1..3).each do |n|
      Factory(:spot, :course=>course, :position=>n)
   end
     Factory(:spot, :course=>course, :name=>'start',:position => nil)
   Factory(:spot, :course=>course, :name=>'end',:position => nil)
    return course
  end
end