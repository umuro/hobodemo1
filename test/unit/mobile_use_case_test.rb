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
      @fleet_race = UseCaseSamples.build_fleet_race
      UseCaseSamples.participate_to_fleet_race :boat => @boat, :fleet_race => @fleet_race
    end
    should "succeed" do
      begin #test requirements
	assert_not_nil @fleet_race.course_area
	assert ! @fleet_race.event.course_areas.empty?
	assert_equal @fleet_race.event.id, Event.active.first.id
      end
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
      fleet_races_today = course_area.fleet_races.today_for(course_area.event).active #REST
      assert ! fleet_races_today.empty?
  # User selects fleet_race
      fleet_race = fleet_races_today.first
      assert_not_nil fleet_race
  # Race should provide the list of participating boats.
      boats = fleet_race.boats #REST
  #B) fleet_race
      fleet_races_today = active_event.fleet_races.today_for(active_event).active #REST
      fleet_race = fleet_races_today.first
      course_area = fleet_race.course_area #REST
      course = fleet_race.course #REST

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
      fleet_race.flags #REST
  # Spotting session should accept a flagging within flags of its race
      flagging = Flagging.create :fleet_race=>fleet_race, :spotter=>@the_spotter, :flagging_time=>Time.now.utc
    end
  end

  #### NOTES ####
  context "User" do
    should "be spotter for an event"
  end

  context "Event" do
    should "have daylight saving"
    should "have exact active_events"
  end

  context "FleetRace" do
    should "be invalid without a course area and a course"
  end
end
