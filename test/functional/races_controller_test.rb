require File.dirname(__FILE__) + '/../test_helper'

require 'test/factories/use_case_samples'
# Mobile Client
class RacesControllerTest < ActionController::TestCase
   context "in Spotting Story, " do
   # Mobile Client
    setup do
      @the_spotter = Factory(:user)
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat 
      @race = UseCaseSamples.build_race 
      UseCaseSamples.participate_to_race_fleet :boat => @boat, :race => @race
    end
    context "wit a course area, " do
      setup {@course_area = @race.course_area}
      should "get races" do
        get :index_for_course_area, :course_area_id => @course_area.id, :format=>'xml'
        assert_response :success
        klass = "Race"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'name',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
      end #should
    end #context
    context "with a race, " do
      should "show" do
        assert_not_nil @race
        get :show, :id => @race.id, :format=>'xml'
        assert_response :success
        klass = "Race"
        assert_tag :tag => 'name',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
        assert_tag :tag => 'event_id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
        assert_tag :tag => 'course_id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
        assert_tag :tag => 'course_area_id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
      end#should
      should "get flags" do
        get :flags, :id=>@race.id, :format=>'xml'
        assert_response :success
        klass = "Flag"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'name',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
      end #should
      should "get boats" do
        get :boats, :id=>@race.id, :format=>'xml'
        assert_response :success
        klass = "Boat"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'name',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
      end #should
    end #context
   end #context
end
