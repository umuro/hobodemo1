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

class EquipmentControllerTest < ActionController::TestCase

  context "Security: " do

    setup {

      user = Factory(:user_profile).owner
      boat_class = Factory(:boat_class)
      boat = Factory(:boat, :owner => user, :boat_class => boat_class)

      equipment_type = Factory(:equipment_type, :boat_class => boat_class)
      @equipment = Factory(:equipment, 
                            :equipment_type => equipment_type,
                            :boat => boat)

      @equipment_attrs = Factory.attributes_for(:equipment, 
                                                :equipment_type => equipment_type,
                                                :boat => boat)
    }

    context "Guest" do
      
      context "(read actions)" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @equipment.id
          assert_response :success
        end
      end

      context "(edit actions)" do

        should "not get new" do
          get :new
#           assert_response :forbidden
          assert_response :success
          assert_no_tag :tag=>'form'
        end 

        should "not get edit" do
          get :edit, :id=>@equipment.id
          assert_response :success
          assert_no_tag :tag=>'form'
        end
      end

      context "(write actions)" do

        should "not post create" do
	  assert_raise(ActionController::UnknownAction) do
	    post :create, :equipment => @equipment_attrs
	  end
#           assert_response :forbidden
        end

        should "not put update" do
        #FIXME There is a hobo bug
# 	  assert_raise do
# 	    put :update, :id => @equipment.id, :equipment => @equipment_attrs
# 	  end
#           assert_response :forbidden
        end

        should "not delete" do
	  assert_raise(ActionController::UnknownAction) do
	    delete :destroy, :id => @equipment.id
	  end
#           assert_response :forbidden
        end
      end

    end

    context "Someone else" do
      setup do 
        @someone_else = Factory(:user_profile).owner
        login_as @someone_else
      end

      context "(write actions)" do

        should "not put update" do
	  #FIXME There is a hobo bug
#           put :update, :id => @equipment.id, :equipment => @equipment_attrs 
#           assert_response :forbidden
        end

        should "not delete" do
	  assert_raise(ActionController::UnknownAction) do
	    delete :destroy, :id => @equipment.id
	  end
#           assert_response :forbidden
        end
      end    
    end

  end
  
end