require File.dirname(__FILE__) + '/../test_helper'

class CourseAreaTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context "Active Record" do
    setup {Factory(:course_area)}
    should belong_to :event #PARENT
    should validate_presence_of :event #PARENT
#     should_validate_uniqueness_of :name, :scoped_to=>:event_id #PARENT
      should validate_uniqueness_of(:name).scoped_to(:event_id)
    should validate_presence_of :name
    
    should have_many :fleet_races
  end
end
