require File.dirname(__FILE__) + '/../test_helper'

class SpotTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:spot)}
    should belong_to :course #PARENT
    should validate_presence_of :course #PARENT
#     should_validate_uniqueness_of :position, :scoped_to=>:course_id #PARENT
      should validate_uniqueness_of(:position).scoped_to(:course_id)
    
    should validate_presence_of :spot_type
    
    should have_many :spottings
  end

  context "A New Mark" do
    setup {
      course = Factory(:course)
      @spot = Spot.new :spot_type=>:Mark, :course=>course}
    subject{@spot}
  end
  context "A lazy New Mark" do
    setup {
      course = Factory(:course)
      @spot = Spot.new :spot_type=>:Mark
      @spot.course = course}
    subject{@spot}
    should "have position" do
      assert_not_nil subject.position
    end
  end
  context "A Mark with lazy course" do
    setup {
      course = Factory(:course)
      @spot = Spot.create :spot_type=>:Mark
      @spot.course = course
    }
    subject{@spot}
    should "have position" do
      assert_not_nil subject.position
    end
  end
  context "A Factorized mark" do
    setup {
      @spot = Factory(:spot)
    }
    subject{@spot}
    should "have position" do
      assert_not_nil subject.position
    end
  end
end
