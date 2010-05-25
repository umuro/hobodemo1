require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

class UseCaseTest < ActiveSupport::TestCase

#   def self.build_boat test
#     boat_class = Factory(:boat_class)
#     (1..3).each do |i|
#       Factory(:equipment_type, :boat_class_id=>boat_class.id)
#     end
# 
#     boat = Factory(:boat, :boat_class=>boat_class)
#     boat_class.equipment_types.each do |et|
#       Factory(:equipment, :equipment_type=>et, :boat=>boat)
#     end
#     return boat
#   end
# 
#   def self.build_race test
#     Factory(:flag) #FIXME "See race.rb; Flags are global temporarily"
#     event = Factory(:event)
# #     race = Factory(:race,  :boat_class=>BoatClass.first)
#     #TODO For an unknown reason we cannot use default event
#     race = Factory(:race, :event=>event, :boat_class=>BoatClass.first)
#     build_master_course test, race
#     return race
#   end
# 
#   def self.build_person test
# 	u = Factory(:user)
#     return Factory(:person, :user=>u)
#   end
# 
#   def self.participate_to_event test, options={}
#     event = options[:event]
#     boat = options[:boat]
#     skipper = options[:skipper]
#     crew_members = options[:crew_members]
#     crew_members ||= []
# 
#     p = Factory(:team_participation, :event=>event, :boat=>boat) #FIXME Prove that boat cannot be reused by events
# 
#     Factory(:crew_member, :team_participation=>p, :person=>skipper, :position=>:S)
# 
#     crew_members.each do | person |
#       Factory(:crew_member, :team_participation=>p, :person=>person)
#     end
#   end
# 
#   def self.participate_to_race_fleet test, options={}
#     boat = options[:boat]
#     race = options[:race]
#     test.assert_not_nil race.default_fleet
#     race.default_fleet.boats << boat
#     race.default_fleet.save!
#   end
# 
#   def self.build_master_course test, race=nil
#      course = Factory(:course, :race=>race)
#     (1..3).each do |n|
#       Factory(:spot, :course=>course, :position=>n)
#    end
#      Factory(:spot, :course=>course, :name=>'start',:position => nil)
# 	 Factory(:spot, :course=>course, :name=>'end',:position => nil)
#     return course
#   end

  context "Global" do
    setup do
      @course = UseCaseSamples.build_master_course 
    end

  context ": Regatta Event " do
    setup do
	  @person = UseCaseSamples.build_person
      @boat = UseCaseSamples.build_boat 
      @_race = UseCaseSamples.build_race 
      @event = @_race.event
      @participation = UseCaseSamples.participate_to_event :event=>@event,
          :boat=>@boat,
          :skipper=>@person
    end

    subject {@event}
    should "have geography" do
      Factory(:course_area, :event=>subject)
    end

    should "prevent duplicate participation"
    should "interact with mobile"

    context ": CourseArea" do
      should "have geographic place"
    end

    context ": Race" do
      setup do
        @race = @_race
      end
      subject {@race}
      should "be partipitated" do
        UseCaseSamples.participate_to_race_fleet :boat=>@boat, :race=>subject
      end
      should "have course area"
    end #context race
  end #context event
  end #context global
end
