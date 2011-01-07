require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'
# Mobile Client

class SpottingsControllerTest < ActionController::TestCase
   context "in Spotting Story, " do
   # Mobile Client
    setup do
      @the_spotter = Factory(:user)
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat 
      @fleet_race = UseCaseSamples.build_fleet_race 
    end
    context "with a spot, " do
      setup do
        @spot = @fleet_race.course.spots.first
      end
      should "post" do
        login_as(@the_spotter)
        t = Time.now.utc
        post :create, :spotting => {:spot_id=>@spot.id, :spotting_time=>t, :boat_id => @boat.id}, :format=>"xml"
         assert_response :success
#         assert_response 302
        obj = Spotting.find_by_spot_id_and_spotting_time(@spot.id, t)
        assert_not_nil obj
        klass = "Spotting"
        assert_tag :tag => 'id',
                      :parent => { :tag => klass.underscore },
                      :content => /[0-9]+/

      end #should
      should "delete" do
        login_as(@the_spotter)
        spotting = Factory(:spotting, :spotter=>@the_spotter, :spot=>@spot, :boat_id =>@boat.id)
        delete :destroy, :id=>spotting.id, :format=>"xml"
        assert_response :success
      end #should
    end
   end #context
end
