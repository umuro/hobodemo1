require File.dirname(__FILE__) + '/../test_helper'

class CalendarEntryTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:calendar_entry)}
    should belong_to :event    #PARENT
    should validate_presence_of :event    #PARENT
    #should_validate_uniqueness_of :name, :scoped_to=>:event_id    #PARENT
    should validate_uniqueness_of(:name).scoped_to(:event_id) #PARENT
  end
end
