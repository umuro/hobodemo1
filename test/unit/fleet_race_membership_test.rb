require 'test_helper'

class FleetRaceMembershipTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:fleet_race_membership)}
    should belong_to :fleet_race #PARENT
    should validate_presence_of :fleet_race #PARENT

    should belong_to :enrollment
    should validate_presence_of :enrollment
  end
end
