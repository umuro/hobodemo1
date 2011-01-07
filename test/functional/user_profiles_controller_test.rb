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

class UserProfilesControllerTest < ActionController::TestCase

  context "Security: " do

    setup { 
      @profile = Factory(:user_profile)
    }

    context "Guest" do

      context "(read actions)" do

        should "not get index" do
          get :index
          assert_response :success, nil
        end

        should "not get show" do
          get :show, :id => @profile.id
          assert_response :forbidden
        end
      end

      context "(edit actions)" do

        should "not get new" do
          get :new
          assert_response :forbidden
          assert_no_tag :tag => 'form'
        end

        should "not get edit" do
          get :edit, :id => @profile.id
          assert_response :forbidden
          assert_no_tag :tag => 'form'
        end
      end
      
      context "(write actions)" do

        setup {
          @profile_attrs = Factory.attributes_for(:user_profile)
        }

        should "not post create" do
          post :create, :user_profile => @profile_attrs
          assert_response :forbidden
        end

        should "not put update" do
          put :update, :id => @profile.id, :user_profile => @profile_attrs 
          assert_response :forbidden
        end

        should "not delete" do
          delete :destroy, :id => @profile.id
          assert_response :forbidden
        end
      end

    end
  end
end