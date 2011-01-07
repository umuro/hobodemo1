require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < ActiveSupport::TestCase

  context "Active Record" do

    setup do 
      Factory(:course)
    end

    should have_many :fleet_races
    should have_many :spots
    should belong_to :organization #PARENT

    should validate_presence_of :organization #PARENT
    should validate_uniqueness_of(:name).scoped_to(:organization_id)
    should validate_presence_of :name
  end

  context "cloning_with_spots" do

    setup do
      @course = Factory(:course)
      spot = Factory(:spot, :course => @course)
    end

    should "respond to :clone_with_spots" do
      assert @course.respond_to? :clone_with_spots
    end
    
    should "include all spots" do

      new_course = @course.clone_with_spots
      assert_not_nil new_course
      assert_not_nil new_course.id
      assert_nil new_course.organization_id

      assert_equal @course.name, new_course.name
      assert_equal @course.spots.count, new_course.spots.count

      spot = @course.spots.sample
      new_spot = new_course.spots.sample
      assert_equal new_spot.name, spot.name
      assert_equal new_spot.position, spot.position
      assert_equal new_spot.spot_type, spot.spot_type
      assert_not_equal new_spot.course_id, spot.course_id
    end
  end
end
