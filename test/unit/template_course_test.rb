require File.dirname(__FILE__) + '/../test_helper'

class TemplateCourseTest < ActiveSupport::TestCase

  context "Active Record" do

    setup do 
      Factory :template_course
    end

    should have_many :spots
    should belong_to :organization #PARENT

    should validate_presence_of :organization #PARENT
    should validate_uniqueness_of(:name).scoped_to(:organization_id)
    should validate_presence_of :name
  end

  context "cloning_with_spots" do

    setup do
      @template_course = Factory :template_course
      Factory :spot, :course => @template_course
    end

	subject { @template_course }

	
    should "respond to :clone_with_spots" do
      assert subject.respond_to? :clone_with_spots
    end
    
    should "include all spots" do

      new_course = subject.clone_with_spots
	  assert new_course.is_a? Course
	  assert_equal false, new_course.is_a?(TemplateCourse)
      assert_not_nil new_course
      assert_not_nil new_course.id
      assert_nil new_course.organization_id

      assert_equal subject.name, new_course.name
      assert_equal subject.spots.count, new_course.spots.count

      spot = subject.spots.sample
      new_spot = new_course.spots.sample
      assert_equal new_spot.name, spot.name
      assert_equal new_spot.position, spot.position
      assert_equal new_spot.spot_type, spot.spot_type
      assert_not_equal new_spot.course_id, spot.course_id
    end
  end
end
