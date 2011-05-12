require 'test_helper'

class FleetRaceMembershipTest < ActiveSupport::TestCase
  context "Active Record" do
    setup do
      @fleet_race_membership = Factory(:fleet_race_membership)
    end

    context "validations" do
      should validate_presence_of :fleet_race #PARENT
      should validate_presence_of :enrollment
    end

    context "relations" do
      should belong_to :fleet_race #PARENT
      should belong_to :enrollment
    end

  end
end
