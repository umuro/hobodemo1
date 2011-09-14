require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

# Mobile Client

class FlaggingsControllerTest < ActionController::TestCase
   context "in Spotting Story, " do
   # Mobile Client
    setup do
      @fleet_race = UseCaseSamples.build_fleet_race
      # We use the event_spotter_role to determine the fact that the user is allowed to submit spottings
      @event_spotter_role = Factory :event_spotter_role, :event => @fleet_race.event
      @the_spotter = @event_spotter_role.user
      @boat = UseCaseSamples.build_boat 
    end
    context "with a flag, " do
      setup do
        @flag = Factory(:flag) #Flag.first
      end
      should "post" do
         login_as(@the_spotter)
        t = Time.now.in_time_zone(@fleet_race.event_tz)
        post :create, :flagging => {:fleet_race_id=>@fleet_race.id, :flag_id=>@flag.id, :flagging_time=>t}, :format=>"xml"
        assert_response :success
        #adjust the time, the properti ignore the timezone information in the value assigned to it since it assume it's in its timezone,
        t -= t.utc_offset.second 
        obj = Flagging.find_by_flag_id_and_flagging_time_and_fleet_race_id(@flag.id, t, @fleet_race.id)
        assert_not_nil obj
        klass = "Flagging"
        assert_tag :tag => 'id',
                      :parent => { :tag => klass.underscore },
                      :content => /[0-9]+/

      end
      should "delete" do
        login_as(@the_spotter)
        flagging = Factory(:flagging, :fleet_race_id=>@fleet_race.id, :flag_id=>Flag.first.id, :spotter_id=>@the_spotter.id)
        delete :destroy, :id=>flagging.id, :format=>"xml"
        assert_response :success
      end #should
      
      context "unauthorized user" do
        setup do
          @the_spotter = Factory :user # Create a new user, which is by default unauthorized
        end
        
        should "not post" do
          login_as(@the_spotter)
          t = Time.now.utc
          post :create, :flagging => {:fleet_race_id=>@fleet_race.id, :flag_id=>@flag.id, :flagging_time=>t}, :format=>"xml"
          assert_response 404
          obj = Flagging.find_by_flag_id_and_flagging_time_and_fleet_race_id(@flag.id, t, @fleet_race.id)
          assert_nil obj
        end #should
        
        should "not delete" do
          login_as(@the_spotter)
          flagging = Factory(:flagging, :fleet_race_id=>@fleet_race.id, :flag_id=>Flag.first.id, :spotter_id=>@event_spotter_role.user.id)
          delete :destroy, :id=>flagging.id, :format=>"xml"
          assert_response 406
        end #should
        
      end
    end
   end #context
end
