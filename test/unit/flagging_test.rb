require File.dirname(__FILE__) + '/../test_helper'

class FlaggingTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:flagging)}
    should belong_to :fleet_race #PARENT
    should validate_presence_of :fleet_race #PARENT

    should belong_to :spotter
    should validate_presence_of :spotter

    should belong_to :flag
    should validate_presence_of :flag
  end
end
