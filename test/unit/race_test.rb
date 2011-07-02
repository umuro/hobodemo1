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
  end
end
