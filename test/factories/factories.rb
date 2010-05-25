require File.join(File.dirname(__FILE__), 'organization_factory')

Factory.define :race do |f|
  class << f
    def default_event
      @default_event ||= Factory(:event)
    end
  end

  f.event { f.default_event }
  f.sequence(:number) {|n| n}
  f.sequence(:name) {|n| n}
  f.planned_time {Time.now.utc.at_beginning_of_day}
  f.start_time {Time.now.utc.at_beginning_of_day}
  f.end_time {Time.now.utc.end_of_day}
  f.gender :O
  f.course_area { |r| Factory(:course_area, :event=>r.event) }
end

Factory.define :boat_class do |f|
  f.sequence(:name) {|n| "class #{n}"}
  f.sequence(:no_of_crew_members) {|n| n}
end

Factory.define :equipment_type do |f|
  f.sequence(:name) {|n| "class #{n}"}
end

Factory.define :equipment do |f|
  f.sequence(:serial) {|n| "class #{n}"}
end

Factory.define :boat do |f|
  f.sequence(:name) {|n| "class #{n}"}
  f.sequence(:sail_number) {|n| "class #{n}"}
end

Factory.define :country do |f|
  f.sequence(:name) {|n| "Country #{n}"}
  f.sequence(:code) {|n| "c#{n}"}
end

Factory.define :person do |f|
  f.sequence(:first_name) {|n| "First#{n}"}
  f.sequence(:last_name) {|n| "Last#{n}"}
  f.sequence(:birthdate) {|n| Time.now - 25.years}
  f.gender { :Female }
#   class << f
#     def default_country
#       @default_country |= Factory(:country)
#     end
#   end
f.country { Factory(:country) }
end
#
# Factory.define :regatta_user, :class => User do |f|
#   f.sequence(:email_address) {|n| "user#{n}@test.com"}
# end

Factory.define :team_participation do |f|
  f.date_entered {Time.now}
  f.sequence(:team_rid) {|n|"regatta id #{n}"}
  f.gender {:Female}
end

Factory.define :crew_member do |f|
  f.position { :C }
end

Factory.define :fleet do |f|
  f.sequence(:color) {|n| "color#{n}"}
  f.gender :M
end

Factory.define :course_area do |f|
  f.sequence(:name) {|n| "course area #{n}"}
end

Factory.define :course do |f|
  f.sequence(:name) {|n| "course #{n}"}
end

Factory.define :spot do |f|
  f.sequence(:name) {|n| "spot #{n}"}
  f.sequence(:position) {|n| n}
  f.spot_type {:Mark}
  #f.course_id {Factory(:course)}
end

Factory.define :spotting do |f|
  f.spotting_time {Time.now}
  f.spotter{ @the_spotter ||= Factory(:person)}
  f.spot{ @the_spot ||= Factory(:spot)}
end

Factory.define :flag do |f|
  f.sequence(:name) {|n| "flag #{n}"}
end

Factory.define :flagging do |f|
  f.flagging_time {Time.now.utc}
end
