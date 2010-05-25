require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

# Mobile Client

class CoursesControllerTest < ActionController::TestCase
   context "in spotting Story, " do
   # Mobile Client
    setup do
      @the_spotter = Factory(:user)
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat 
      @race = UseCaseSamples.build_race 
    end
    context "with a course, " do
      setup {@course=@race.course}
      should  "show" do
        get :show, :id => @course.id, :format=>'xml'
        assert_response :success
        klass = "Course"
        assert_tag :tag => 'name',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
        assert_tag :tag => 'race_id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
        assert_tag :tag => 'spots',
                              :parent => { :tag => klass.underscore }
        klass = "Spot"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'position',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
        assert_tag :tag => 'spot_type',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
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
