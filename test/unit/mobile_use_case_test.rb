require File.dirname(__FILE__) + '/../test_helper'

require 'test/factories/use_case_samples'

class MobileUseCaseTest < ActiveSupport::TestCase

# course_area
#   spots {id, name, type[report, finish, ocs, mark]}
#      spottings {boat_id, timestamp}
#   coming_races
#      flags {id,name}
#      flaggings {flag_id}

  #Mobile preferences should have active event
  #Event class should have active events
  #Mobile stores preferred login
  #User should login
  #user should have spotter to use mobile interface
  context "Spotting Story" do
    setup do
      @the_spotter = Factory(:user)
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat
      @race = UseCaseSamples.build_race
      UseCaseSamples.participate_to_race_fleet:boat => @boat, :race => @race
    end
    should "succeed" do

  # Event should provide active events
      active_events = Event.active #REST
      assert ! active_events.empty?
  #User sometime selects active events
      active_event = active_events.first

  #A) course_area -> race
  # Active event should provide course areas
      course_areas = active_event.course_areas #REST
      assert ! course_areas.empty?
  # User selects course area
      course_area = course_areas.first
      assert_not_nil course_area
  # Course area should provide today's active races (for itself)
      races_today = course_area.races.today.active #REST
      assert ! races_today.empty?
  # User selects race
      race = races_today.first
      assert_not_nil race
  # Race should provide the list of participating boats.
      boats = race.boats #REST
  #B) race
      races_today = active_event.races.today.active #REST
      race = races_today.first
      course_area = race.course_area #REST
      course = race.course #REST

  #And then ...
  # Course should provide spots
      spots = course.spots #REST in race.course
  # User should checkin at a spot for a race to get a spotting session
      spot = spots.first
#       spot.spotter_ready #TODO
  # Spotting session should accept spottings (boat_id)
      spotting = Spotting.create :spot=>spot, :spotter=>@the_spotter, :spotting_time=>Time.now.utc #REST
  # Spotting session observer should exist for later business logics
  # Spotting session should provide flags (from its race)
      race.flags #REST
  # Spotting session should accept a flagging within flags of its race
      flagging = Flagging.create :race=>race, :spotter=>@the_spotter, :flagging_time=>Time.now.utc
    end
  end

  #### NOTES ####
  context "User" do
    should "be spotter for an event"
  end

  context "Event" do
    should "have daylight saving"
    should "have exact active_events"
    should "have a life cycle .e.g defined, published, finished"
  end

  context "Race" do
    should "be invalid without a course area"
    should "be invalid if course area event is not matching"
  end
end