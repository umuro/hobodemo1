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
 
class OrganizationsControllerTest < ActionController::TestCase
  context "Security:  " do
    setup { 
      @organization = Factory(:organization)
      @attrs = Factory.attributes_for(:organization) }
    context "Guest" do
      #setup {login_as somebody}
      context "(read_actions)" do
        should "get index" do
          get :index
          assert_response :success
        end
        should "get show" do
          get :show, :id=>@organization.id
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
          get :edit, :id=>@organization.id
          assert_response :success
          assert_no_tag :tag=>'form'
        end
      end
      context "(write_actions)" do
        should "not post create" do
          count1 = Organization.count
          post :create, :organization => @attrs 
          count2 = Organization.count
          assert_equal count1, count2, "Nothing created"
          assert_response :forbidden
        end
        should "not put update" do
          put :update, :id=>@organization.id, :organization => @attrs 
          assert_response :forbidden
        end
        should "not delete" do
          delete :destroy, :id=>@organization.id
          assert_response :forbidden
        end
      end
    end
  end
end