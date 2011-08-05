require File.dirname(__FILE__) + '/../test_helper'

class RaceTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:race)}
    should belong_to :event #PARENT   
    should validate_presence_of :event #PARENT
#     should_validate_uniqueness_of :number, :scoped_to=>:event_id #PARENT
      should validate_uniqueness_of(:number).scoped_to(:event_id)
    should validate_presence_of :number
    
    should have_many :fleet_races
  end

  context "Boat Class choices" do
    setup do
      @event = Factory(:event)
      @organization = @event.organization
      @bc_0 = Factory(:boat_class, :organization=>@organization)
      @bc_1 = Factory(:boat_class, :organization=>@organization)
    end

    context "Event doesn't have boat classes" do
      setup do
        @race = Factory(:race, :event=>@event)
      end

      context "@race.available_boat_classes" do
        should "return all boat classes from organization" do
          assert_equal @race.available_boat_classes.length,2
          assert_equal @race.available_boat_classes, [@bc_0, @bc_1]
        end
      end
    end

    context "Event have boat classes" do
      setup do
        @race = Factory(:race, :event=>@event)
        @event.boat_classes << @bc_0
      end

      context "@race.available_boat_classes" do
        should "return boat classes from event" do
          assert_equal @race.available_boat_classes.length,1
          assert_equal @race.available_boat_classes, [@bc_0]
        end
      end
    end
  end #Boat Class choices

  context "Advanced Fleet Management" do
    setup do
      @race = Factory(:race)
      @race_x = Factory(:race)
      rr = Factory :registration_role, :event=>@race.event
      @enrollment_0 = Factory :enrollment, :registration_role => rr
      @enrollment_1 = Factory :enrollment, :registration_role => rr
      @enrollment_2 = Factory :enrollment, :registration_role => rr
      @fleet_race_0 = Factory(:fleet_race, :race=>@race)
      Factory(:fleet_race_membership, :fleet_race=>@fleet_race_0, :enrollment=>@enrollment_0)
      Factory(:fleet_race_membership, :fleet_race=>@fleet_race_0, :enrollment=>@enrollment_1)
      @fleet_race_1 = Factory(:fleet_race, :race=>@race_x)
      Factory(:fleet_race_membership, :fleet_race=>@fleet_race_1, :enrollment=>@enrollment_2)
    end

      should "respond to available_enrollments helper methods" do
        assert @race.respond_to? :available_enrollments
      end

      should "return unassigned enrollments via available_enrollments" do
        assert_equal @race.event.enrollments.length, 3

        assert_equal @race.available_enrollments.length, 1
        assert_equal @race.available_enrollments[0].id, @enrollment_2.id

        assert_equal @race_x.available_enrollments.length, 2
        assert @race_x.available_enrollments.include? @enrollment_0
        assert @race_x.available_enrollments.include? @enrollment_1
      end
  end #Advanced Fleet Management

end
