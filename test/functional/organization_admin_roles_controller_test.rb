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
 
class OrganizationAdminRolesControllerTest < ActionController::TestCase
  context "Security:  " do
    setup { 
      @organization_admin_role = Factory(:organization_admin_role)
      @attrs = Factory.attributes_for(:organization_admin_role) }
    context "Guest" do
      #setup {login_as somebody}
      context "(read_actions)" do
        should "get index" do
          get :index
          assert_response :success
        end
        should "get show" do
          get :show, :id=>@organization_admin_role.id
          assert_response :success
        end
      end
      context "(edit actions)" do
        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag=>'form'
        end 
        should "not get edit" do
          get :edit, :id=>@organization_admin_role.id
          assert_response :success
          assert_no_tag :tag=>'form'
        end
      end
      context "(write_actions)" do
        should "not post create" do
          count1 = OrganizationAdminRole.count
          post :create, :organization_admin_role => @attrs 
          count2 = OrganizationAdminRole.count
          assert_equal count1, count2, "Nothing created"
          assert_response :forbidden
        end
        should "not put update" do
          put :update, :id=>@organization_admin_role.id, :organization_admin_role => @attrs 
          assert_response :forbidden
        end
        should "not delete" do
          delete :destroy, :id=>@organization_admin_role.id
          assert_response :forbidden
        end
      end
    end
  end
end