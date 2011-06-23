require File.dirname(__FILE__) + '/../test_helper'

class EventSpotterRoleTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory :event_spotter_role}
    should belong_to :event #PARENT
    should validate_presence_of :event #PARENT
    
    should belong_to :user
    should validate_presence_of :user
  end
  
  context "Test for Index" do
    setup {@event_spotter_role_params = Factory.attributes_for :event_spotter_role}
    subject {@event_spotter_role_params}
    
    should "Not allow the same event spotter role to be created twice" do
      EventSpotterRole.create @event_spotter_role_params
      assert_raise (ActiveRecord::StatementInvalid){ EventSpotterRole.create @event_spotter_role_params }
    end
  end
end
