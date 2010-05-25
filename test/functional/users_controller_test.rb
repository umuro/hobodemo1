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

class UsersControllerTest < ActionController::TestCase
  context "Security:  " do
    setup { 
      @user = Factory(:user)
      @attrs = Factory.attributes_for(:user) }
    context "Guest" do
      #setup {login_as somebody}
      context "(read_actions)" do
        should "get index" do
          get :index
          assert_response :success
        end
        should "get show" do
          get :show, :id=>@user.id
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
          get :edit, :id=>@user.id
          assert_response :success
          assert_no_tag :tag=>'form'
        end
      end
      context "(write_actions)" do
        should "not post create" do
          assert_raise(ActionController::UnknownAction) { post :create, :user => @attrs }
        end
#TODO Hobo Security Hole
#         should "not put update" do
#           put :update, :id=>@user.id, :user => @attrs 
#           assert_response :forbidden
#         end
        should "not delete" do
          delete :destroy, :id=>@user.id
          assert_response :forbidden
        end
      end
    end
  end
end
