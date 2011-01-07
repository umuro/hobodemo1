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
end
