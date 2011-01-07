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

class BoatsControllerTest < ActionController::TestCase

  context "Security: " do

    setup { 
      @boat = Factory(:boat)
    }

    context "Guest" do
      
      context "(read actions)" do

        should "not get index" do
          get :index
          assert_response :success
        end

        should "not get show" do
          get :show, :id => @boat.id
          assert_response :success
          assert_no_tag :tag =>'form'
        end
      end

      context "(edit actions)" do

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag=>'form'
        end 

        should "not get edit" do
          get :edit, :id=>@boat.id
          assert_response :success
          assert_no_tag :tag=>'form'
        end
      end
      
      context "(write actions)" do

        setup {
          @boat_attrs = Factory.attributes_for(:boat)
        }

        should "not post create" do
          post :create, :boat => @boat_attrs
          assert_response :forbidden
        end

        should "not put update" do
          put :update, :id => @boat.id, :boat => @boat_attrs 
          assert_response :forbidden
        end

        should "not delete" do
          delete :destroy, :id => @boat.id
          assert_response :forbidden
        end
      end

    end
  
    context "Someone else" do
      setup do 
        @someone_else = Factory(:user)
        login_as @someone_else
      end

      context "(write actions)" do

        setup {
          @boat_attrs = Factory.attributes_for(:boat)
        }

        should "not put update" do
          put :update, :id => @boat.id, :boat => @boat_attrs 
          assert_response :forbidden
        end

        should "not delete" do
          delete :destroy, :id => @boat.id
          assert_response :forbidden
        end
      end    
    end
    
  end
end