require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

class UseCaseTest < ActiveSupport::TestCase

  context "Global" do
  context ": Regatta Event " do
    setup do
#       @user_profile = UseCaseSamples.build_user_profile
      @boat = UseCaseSamples.build_boat 
      @fleet_race = UseCaseSamples.build_fleet_race
      @event = @fleet_race.event
#       @enrollment = UseCaseSamples.enroll_to_event :event=>@event,
#           :boat=>@boat,
#           :skipper=>Factory(:user) 
    end

    subject {@event}
    should "have geography" do
      Factory(:course_area, :event=>subject)
    end

    should "prevent duplicate participation"

#     context ": CourseArea" do
#       should "have geographic place"
#     end

    context ": FleetRace" do
      subject {@fleet_race}
      should "be partipitated" do
        UseCaseSamples.participate_to_fleet_race :boat=>@boat, :fleet_race=>subject
      end
      should "have course area" do
	assert_not_nil subject.course_area
      end
    end #context race
  end #context event
  end #context global
end
