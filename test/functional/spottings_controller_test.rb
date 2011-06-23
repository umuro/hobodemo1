require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'
# Mobile Client

class SpottingsControllerTest < ActionController::TestCase
   context "in Spotting Story, " do
   # Mobile Client
    setup do
      @fleet_race = UseCaseSamples.build_fleet_race
      # We use the event_spotter_role to determine the fact that the user is allowed to submit spottings
      @event_spotter_role = Factory :event_spotter_role, :event => @fleet_race.event
      @the_spotter = @event_spotter_role.user
      @boat = UseCaseSamples.build_boat 
    end
    context "with a spot, " do
      setup do
        @spot = @fleet_race.course.spots.first
      end
      should "post" do
        
        # The spotter is supposed to be logged in and referred to as spotter
        
        login_as(@the_spotter)
        t = Time.now.utc
        post :create, :spotting => {:spot_id=>@spot.id, :spotting_time=>t, :boat_id => @boat.id}, :format=>"xml"
         assert_response :success
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

      context "unauthorized user" do
        setup do
          @the_spotter = Factory :user # Create a new user, which is by default unauthorized
        end
        
        should "not post" do
          login_as(@the_spotter)
          t = Time.now.utc
          post :create, :spotting => {:spot_id=>@spot.id, :spotting_time=>t, :boat_id => @boat.id}, :format=>"xml"
          assert_response 404
          obj = Spotting.find_by_spot_id_and_spotting_time(@spot.id, t)
          assert_nil obj
        end #should
        
        should "not delete" do
          login_as(@the_spotter)
          spotting = Factory(:spotting, :spotter=>@event_spotter_role.user, :spot=>@spot, :boat_id =>@boat.id)
          delete :destroy, :id=>spotting.id, :format=>"xml"
          assert_response 406
        end #should
        
      end
    end
   end #context
end
