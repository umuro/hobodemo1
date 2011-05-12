require File.dirname(__FILE__) + '/../test_helper'

class RacesControllerTest < ActionController::TestCase
  context "Advanced Fleet Management" do
    setup do
      @race = Factory(:race)
    end

    context "Someone else" do
      setup do
        someone_else = Factory(:user)
        login_as someone_else
      end

      should "not see available boats/enrollments" do
        get :show, :id=>@race.id
        assert_no_tag :attributes => { :id=>'available'}
      end
    end

    context "Organization Admin" do
      setup do
        user = Factory(:user)
        Factory(:organization_admin_role, :organization=>@race.organization, :user=>user)
        login_as user
      end

      should "see available boats/enrollments" do
        get :show, :id=>@race.id
        assert_tag :attributes => { :id=>'available'}
      end
    end
  end
end
