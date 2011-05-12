
require File.join(File.dirname(__FILE__), 'organization_factory')

Factory.define :boat_class do |f|
  f.sequence(:name) {|n| "class #{n}"}
  f.sequence(:no_of_crew_members) {|n| n}
end

Factory.define :equipment_type do |f|
  class << f
    def default_boat_class
      @default_boat_class = Mill.unless_produced?(:boat_class, @default_boat_class)
    end
  end
  
  f.sequence(:name) {|n| "class #{n}"}
  f.boat_class { f.default_boat_class }
end

Factory.define :equipment do |f|
  class << f
    def default_boat
      @default_boat = Mill.unless_produced?(:boat, @default_boat)
    end
  end
  
  f.sequence(:serial) {|n| "class #{n}"}
  f.boat { f.default_boat }
  f.equipment_type { |p| Factory :equipment_type, :boat_class => p.boat.boat_class }
end

Factory.define :boat do |f|
  class << f
    def default_boat_class
      @default_boat_class = Mill.unless_produced?(:boat_class, @default_boat_class)
    end
  end
  
  f.sequence(:sail_number) {|n| "SN#{n}"}
  f.owner { Factory(:user) }
  f.boat_class { f.default_boat_class }
end



#
# Factory.define :regatta_user, :class => User do |f|
#   f.sequence(:email_address) {|n| "user#{n}@test.com"}
# end

# Factory.define :enrollment do |f|
# #TODO
# #    f.date_entered {Time.now.utc }
#    f.sequence(:team_rid) {|n|"regatta id #{n}"}
#    f.owner { Factory(:user) }
#    f.event { Factory(:event) }
#    f.boat { Factory(:boat) }
#    f.crew { Factory(:crew) }
# end

Factory.define :crew_membership do |f|

  class << f
    def default_crew
      @default_crew = Mill.unless_produced?(:crew, @default_crew) #Factory(:crew)
    end
    def default_user
      @default_user = Mill.unless_produced?(:user, @default_user) #Factory(:user)
    end
  end

  f.joined_crew { f.default_crew }
  #f.owner { f.default_crew.owner }
  f.invitee { f.default_user }
end

Factory.define :crew do |f|
  f.owner { Factory(:user) }
  f.gender { :Open }
  f.sequence(:name) { |n| "crew_#{n}" }
end

Factory.define :race do |f|
  class << f
    def default_event
      @default_event = Mill.unless_produced?(:event, @default_event) #Factory(:event)
    end
  end

  f.event { f.default_event }
  f.sequence(:number) {|n| n}
  f.boat_class { Factory(:boat_class) }
  f.gender :Open
end

Factory.define :fleet_race do |f|
  class << f
    def default_race
      @default_race = Mill.unless_produced?(:race, @default_race)#Factory(:race)
    end
  end
  
  f.race { f.default_race }
  
  f.sequence(:color) {|n| "color#{n}"}
  
  # CAUTION:
  # ========
  # The scheduled time is determined according to the event's time zone which is stored in the race.
  # It is not possible to use default_race, as it will not be the proper time zone when the race is set through
  # a hash property such as Factory :fleet_race, :race => ...
  
  f.scheduled_time {|p| Time.now.in_time_zone(p.race.event.time_zone).at_beginning_of_day+9.hours}
  
  # Start time and end time are default nil
  
  f.start_time { nil }
  f.end_time { nil }

  f.course_area { |r| Factory(:course_area, :event=>r.event) }
end

Factory.define :fleet_race_membership do |f|
  f.fleet_race { UseCaseSamples.build_fleet_race }
  f.enrollment { Factory(:enrollment) }
end
  
Factory.define :course_area do |f|
  class << f
    def default_event
      @default_event =  Mill.unless_produced?(:event, @default_event) #Factory(:event)
    end
  end
  f.event {f.default_event}
  f.sequence(:name) {|n| "course area #{n}"}
end

Factory.define :course do |f|
  f.organization { nil }
  f.type { nil }
  f.sequence(:name) {|n| "course #{n}"}
end

Factory.define :template_course do |f|
  class << f
    def default_organization
      @default_organization = Mill.unless_produced?(:organization, @default_organization)#Factory(:organization)
    end
  end
  f.organization { f.default_organization }
  f.type { 'TemplateCourse' }
  f.sequence(:name) {|n| "course #{n}"}
end

Factory.define :spot do |f|
  class << f
    def default_course
      @default_course = Mill.unless_produced?(:course, @default_course) #Factory(:course)
    end
  end

#   f.sequence(:position) {|n| n}
  f.course {f.default_course}
  f.spot_type {:Mark}
end

Factory.define :spotting do |f|
  f.spotting_time {Time.now}
  f.spotter{ Factory(:user) }
  f.spot{ Factory(:spot) }
  f.boat { Factory(:boat) }
end

Factory.define :flag do |f|
  f.sequence(:name) {|n| "flag #{n}"}
end

Factory.define :flagging do |f|
  class << f
    def default_fleet_race
      @default_fleet_race = Mill.unless_produced?(:fleet_race, @default_fleet_race)  do
	UseCaseSamples.build_fleet_race
      end
    end
  end
 
  f.fleet_race { f.default_fleet_race }
  f.spotter {Factory(:user)}
  f.flag {Factory(:flag)}
  f.flagging_time {Time.now.utc}
end

Factory.define :calendar_entry do |f|
  class << f
    def default_event
      @default_event = Mill.unless_produced?(:event, @default_event) #Factory(:event)
    end
  end
  f.event {f.default_event}
  f.sequence(:name) {|n| "calendar entry #{n}"}
  f.scheduled_time {Time.now.utc.at_beginning_of_day}
end


