require File.dirname(__FILE__) + '/../test_helper'

#See
#   https://github.com/thoughtbot/shoulda
#   http://guides.rubyonrails.org/testing.html#functional-tests-for-your-controllers

# GET    /items        #=> index
# GET    /items/1      #=> show
# GET    /items/new    #=> new
# GET    /items/1/edit #=> edit
# PUT    /items/1      #=> update
# POST   /items        #=> create
# DELETE /items/1      #=> destroy

class EventSpotterRolesControllerTest < ActionController::TestCase
  
  context "Security:  " do
    setup do
      @event_spotter_role = Factory :event_spotter_role
      @attrs = Factory.attributes_for :event_spotter_role
      Factory(:user_profile, :owner=>@event_spotter_role.user)

    end
    context "Guest" do
      #setup {login_as somebody}
      context "(read actions)" do
        should "get index" do
          get :index
          assert_response :success
        end
        should "get show" do
          get :show, :id=>@event_spotter_role.id
          assert_response :success
        end
      end
      context "(edit actions)" do
        should "not get new" do
          get :new_for_event, :event_id => @event_spotter_role.event.id
          assert_response :success
          assert_no_tag :tag=>'form'
        end 
        should "not get edit" do
          get :edit, :id=>@event_spotter_role.id
          assert_response :success
          assert_no_tag :tag=>'form'
        end
      end
      context "(write_actions)" do
        should "not post create" do
          esr = Factory.attributes_for :event_spotter_role, :user => Factory(:user_profile).owner, :event => @event_spotter_role.event
          count1 = EventSpotterRole.count
          post :create_for_event, :event_id => esr[:event].id, :event_spotter_role => esr
          count2 = EventSpotterRole.count
          assert_equal count1, count2, "Nothing created"
          assert_response :forbidden
        end
        should "not put update" do
          put :update, :id=>@event_spotter_role.id, :event_spotter_role => @attrs 
          assert_response :forbidden
        end
        should "not delete" do
          delete :destroy, :id=>@event_spotter_role.id
          assert_response :forbidden
        end
      end
    end
    
    
    
    context "Organization Admin" do
      setup do
        @organization_admin_role = Factory :organization_admin_role, :organization => @event_spotter_role.organization
        @organization_admin = @organization_admin_role.user
	Factory(:user_profile, :owner=>@organization_admin)
        login_as @organization_admin
      end
      context "(read actions)" do
        should "get index" do
          get :index
          assert_response :success
        end
        should "get show" do
          get :show, :id=>@event_spotter_role.id
          assert_response :success
        end
      end
      context "(edit actions)" do
        should "get new" do
          get :new_for_event, :event_id => @event_spotter_role.event.id
          assert_response :success
          assert_tag :tag=>'form'
        end 
        should "get edit" do
          get :edit, :id=>@event_spotter_role.id
          assert_response :success
          assert_tag :tag=>'form'
        end
      end
      context "(write_actions)" do
        should "post create" do
          esr = Factory.attributes_for :event_spotter_role, :user => Factory(:user_profile).owner, :event => @event_spotter_role.event
          count1 = EventSpotterRole.count
          post :create_for_event, :event_id => esr[:event].id, :event_spotter_role => esr
          count2 = EventSpotterRole.count
          assert_not_equal count1, count2
          assert_response :redirect
        end
        should "put update" do
          put :update, :id=>@event_spotter_role.id, :event_spotter_role => @attrs 
          assert_response :redirect
        end
        should "delete" do
          delete :destroy, :id=>@event_spotter_role.id
          assert_response :redirect
        end
      end
    end
  end
end