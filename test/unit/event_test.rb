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

  context "Advanced Fleet Management" do
    setup do
      @race = Factory(:race)
      rr = Factory :registration_role, :event=>@race.event
      @enrollment_0 = Factory :enrollment, :registration_role => rr
      @enrollment_1 = Factory :enrollment, :registration_role => rr
      @enrollment_2 = Factory :enrollment, :registration_role => rr
      @fleet_race_0 = Factory(:fleet_race, :race=>@race)
      Factory(:fleet_race_membership, :fleet_race=>@fleet_race_0, :enrollment=>@enrollment_0)
      @fleet_race_1 = Factory(:fleet_race, :race=>@race)
      Factory(:fleet_race_membership, :fleet_race=>@fleet_race_1, :enrollment=>@enrollment_1)
    end

    context "the event object" do
      should "respond to available_enrollments helper methods" do
        assert @race.event.respond_to? :available_enrollments
      end

      should "return unassigned enrollments via available_enrollments" do
        assert_equal @race.event.enrollments.length, 3
        assert_equal @race.event.available_enrollments.length, 1
        assert_equal @race.event.available_enrollments[0].id, @enrollment_2.id
      end
    end
  end
end
