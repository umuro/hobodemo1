require File.dirname(__FILE__) + '/../test_helper'

class FleetRaceMembershipsControllerTest < ActionController::TestCase
  context "Security: " do
    setup {
      @fleet_race_membership = Factory(:fleet_race_membership)

      @race = Factory(:race, :event=>@fleet_race_membership.event)
      @fleet_race = Factory(:fleet_race, :race=>@race)
      @registration_role = Factory(:registration_role, :event => @race.event)
      @enrollment = Factory(:enrollment, :registration_role => @registration_role)
    }

    context "Someone else" do
      setup do
        someone_else = Factory(:user_profile).owner
        login_as someone_else
      end

      context "(write actions)" do
        setup {
          @fleet_race_membership_attrs = Factory.attributes_for(:fleet_race_membership, :fleet_race=>@fleet_race, :enrollment=>@enrollment)
        }
        should "not put update" do
          put :update, :id => @fleet_race_membership.id, :fleet_race_membership => @fleet_race_membership_attrs
          assert_response :forbidden
        end
        should "not delete" do
          delete :destroy, :id => @fleet_race_membership.id
          assert_response :forbidden
        end
      end
    end # Someone else

    context "Organization Admin" do
      setup do
        user = Factory(:user_profile).owner
        Factory(:organization_admin_role, :organization=>@race.organization, :user=>user)
        login_as user
      end

      context "(write actions)" do
        setup {
          @fleet_race_membership_attrs = Factory.attributes_for(:fleet_race_membership, :fleet_race=>@fleet_race, :enrollment=>@enrollment)
        }
        should "able to post create" do
          post :create, :fleet_race_membership => @fleet_race_membership_attrs
          assert_response :success
        end
        should "able to put update" do
          put :update, :id => @fleet_race_membership.id, :fleet_race_membership => @fleet_race_membership_attrs
          assert_response :redirect
        end
        should "able to delete" do
          delete :destroy, :id => @fleet_race_membership.id
          assert_response :redirect
        end
      end
    end # Organization Admin
  end # Security
end
