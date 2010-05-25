require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

# Mobile Client

class CourseAreasControllerTest < ActionController::TestCase
  context "in Spotting Story, " do
   # Mobile Client
    setup do
      @the_spotter = Factory(:user)
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat 
      @race = UseCaseSamples.build_race 
    end
    context "with an event, " do
      setup {@event = @race.event}
      should "get course areas" do
        get :index_for_event, :event_id => @event.id, :format=>'xml'
        assert_response :success
        klass = "CourseArea"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'name',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
      end
    end
    context "with a course area, " do
      setup {@course_area = @race.course_area}

      should "show" do
        get :show, :id => @course_area.id, :format=>'xml'
        assert_response :success
        klass = "CourseArea"
        assert_tag :tag => 'name',
                             :parent => { :tag => klass.underscore },
                             :content => /.+/
        assert_tag :tag => 'id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
        assert_tag :tag => 'event_id',
                             :parent => { :tag => klass.underscore },
                             :content => /[0-9]+/
      end #should

      should "get today's active races'" do
        get :todays_active_races, :id => @course_area.id, :format=>'xml'
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

  end
end
