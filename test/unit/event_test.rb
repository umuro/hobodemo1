require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:event)}
    should belong_to :event_folder   #PARENT
    should validate_presence_of :event_folder #PARENT
#     should_validate_uniqueness_of :name, :scoped_to=>:event_folder_id #PARENT
      should validate_uniqueness_of(:name).scoped_to(:event_folder_id)
    should validate_presence_of :name  
    
    should have_many :boats
    should have_many :races
    should have_many :course_areas    
    should have_many :enrollments
  end
  
  context "A new event" do
    setup {@event=Factory.build(:event)}
    subject {@event}
    should "have default registration_only" do
      v = EVENT_CONFIG[:registration_only]
      assert_equal v, subject.registration_only
    end
  end
  
  context "A stored event" do
    setup {@event=Factory.create(:event)}
    subject {@event}
    should "have default registration_only stored" do
      v = EVENT_CONFIG[:registration_only]
      assert_equal v, subject[:registration_only]
    end
  end
end
