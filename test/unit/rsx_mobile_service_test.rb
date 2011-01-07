require File.dirname(__FILE__) + '/../test_helper'

require File.dirname(__FILE__) + '/../rsx_mobile_service_helper.rb'

class RsxMobileServiceTest < ActiveSupport::TestCase
  
  context "Jobs Primitives" do
    should "have queue in Call" do
      assert_equal :call_queue, RsxMobileServiceJobs::Call.queue
    end
    
    
    should "have queue in PositionUpdate" do
      assert_equal :position_update_queue, RsxMobileServiceJobs::PositionUpdate.queue
    end
  end
  
  context "Rsx Lifecycle" do
    setup do
      Resque.__metaclass__.send(:alias_method_chain, :enqueue, :stubbing)
      Redis.__metaclass__.send(:alias_method_chain, :current, :stubbing)
    end
    
    teardown do
      Resque.__metaclass__.send(:alias_method, :enqueue, :enqueue_without_stubbing)
      Resque.__metaclass__.send(:remove_method, :enqueue_without_stubbing)
      Redis.__metaclass__.send(:alias_method, :current, :current_without_stubbing)
      Redis.__metaclass__.send(:remove_method, :current_without_stubbing)
    end
    
    should "have lifecycle create method ready" do
      assert RsxMobileService::Lifecycle.respond_to? :ready
    end
    
    context "On New" do
      setup do
        @rms_object = RsxMobileService.new
      end
      
      should "have api_key set to a value" do
        assert_nil @rms_object.api_key
      end
      
      should "have state equals nil" do
        assert_nil @rms_object.state
      end
      
    end
    
    context "On Ready" do
      
      setup do
        $RSX_MOBILE_SERVICE_CALL_EXECUTED = false
        event = Factory :event
        @rms_object = RsxMobileService::Lifecycle.ready(Factory(:user))
        @rms_object.event = event
        @rms_object.save!
      end
      
      should belong_to :event
      
      should "have executed Call" do
        assert_equal true, $RSX_MOBILE_SERVICE_CALL_EXECUTED
      end
      
      should "not re-execute Call" do
        $RSX_MOBILE_SERVICE_CALL_EXECUTED = false
        Redis.current.set "rsx_mobile_service_too_late:#{@rms_object.id}", 0
        Redis.current.setex "rsx_mobile_service_discharge:#{@rms_object.id}", 60, ""
        @rms_object.touch
        assert_equal false, $RSX_MOBILE_SERVICE_CALL_EXECUTED
      end
      
      should "re-execute Call" do
        $RSX_MOBILE_SERVICE_CALL_EXECUTED = false
        sleep 1
        @rms_object.touch
        assert_equal true, $RSX_MOBILE_SERVICE_CALL_EXECUTED
      end
      
      should "re-execute Call two times" do
        for v in 1..2
          $RSX_MOBILE_SERVICE_CALL_EXECUTED = false
          sleep 1
          @rms_object.touch
          assert_equal true, $RSX_MOBILE_SERVICE_CALL_EXECUTED
        end
      end
      
      should "have state set to accept_position_update" do
        assert_equal "accept_position_update", @rms_object.state
      end
    end
  end
end
