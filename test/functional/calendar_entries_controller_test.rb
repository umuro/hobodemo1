require File.dirname(__FILE__) + '/../test_helper'

class CalendarEntriesControllerTest < ActionController::TestCase

  context "Security: " do
    setup {
      @entry = Factory(:calendar_entry)
    }

    context "Someone else" do
      setup do
        @someone_else = Factory(:user)
        login_as @someone_else
      end

      context "(write actions)" do
        setup {
          @entry_attrs = Factory.attributes_for(:calendar_entry, :event=>@entry.event)
        }
        should "not put update" do
          put :update, :id => @entry.id, :calendar_entry => @entry_attrs
          assert_response :forbidden
        end
        should "not delete" do
          delete :destroy, :id => @entry.id
          assert_response :forbidden
        end
      end
    end # Someone else

    context "Organization Admin" do
      setup do
        user = Factory(:user)
        Factory(:organization_admin_role, :organization=>@entry.event.organization, :user=>user)
        login_as user
      end

      context "(write actions)" do
        setup {
          @entry_attrs = Factory.attributes_for(:calendar_entry, :event=>@entry.event)
        }
        should "able to post create" do
          post :create, :calendar_entry => @entry_attrs
          assert_response :redirect
        end
        should "able to put update" do
          put :update, :id => @entry.id, :calendar_entry => @entry_attrs
          assert_response :redirect
        end
        should "able to delete" do
          delete :destroy, :id => @entry.id
          assert_response :redirect
        end
      end
    end # Organization Admin
  end # Security
end
