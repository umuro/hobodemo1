require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

# Mobile Client

class FlaggingsControllerTest < ActionController::TestCase
   context "in Spotting Story, " do
   # Mobile Client
    setup do
      @the_spotter = Factory(:user)
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat 
      @race = UseCaseSamples.build_race 
    end
    context "with a flag, " do
      setup do
        @flag = Flag.first
      end
      should "post" do
         login_as(@the_spotter)
        t = Time.now.utc
        post :create, :flagging => {:race_id=>@race.id, :flag_id=>@flag.id, :flagging_time=>t}, :format=>"xml"
         assert_response :success
#         assert_response 302
        obj = Flagging.find_by_flag_id_and_flagging_time_and_race_id(@flag.id, t, @race.id)
        assert_not_nil obj
        klass = "Flagging"
        assert_tag :tag => 'id',
                      :parent => { :tag => klass.underscore },
                      :content => /[0-9]+/

      end
      should "delete" do
        login_as(@the_spotter)
        flagging = Factory(:flagging,:race_id=>@race.id, :flag_id=>Flag.first.id, :spotter_id=>@the_spotter.id)
        delete :destroy, :id=>flagging.id, :format=>"xml"
        assert_response :success
      end #should
    end
   end #context
end
