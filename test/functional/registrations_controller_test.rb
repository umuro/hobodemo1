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

class RegistrationsControllerTest < ActionController::TestCase

  context "Guest" do

    setup do
      user = Factory(:user)
      country = Factory(:country)
      registration_role = Factory :registration_role

      @registration = Factory(:registration, :owner=>user)
      assert_not_nil @registration.id

      @registration_params = {:registration_role_id => registration_role.id}
    end

    context "CRUD actions" do

      context "write actions" do

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :registration => @registration_params
          end
        end

        should "not delete" do
          assert_raise(ActionController::UnknownAction) do
            delete :destroy, :id=>@registration.id
          end
        end
      end #write actions

      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @registration.id
          assert_response :success
        end
      end #read actions

      context "edit actions" do

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @registration.id
          assert_response :success
        end

        context "put update" do

          should "fail for #registration_role" do
	    registration_role = Factory :registration_role
	    put :update, :id=>@registration.id, :registration => {:registration_role_id=>registration_role.id}
	    assert_response :forbidden

	    registration = Registration.find(@registration.id)
	    assert_not_equal registration.registration_role_id, registration_role.id
          end

          should "fail for #owner" do
            owner = Factory(:user)
            put :update, :id=>@registration.id, :registration => {:owner_id=>owner.id}
            assert_response :forbidden

            registration = Registration.find(@registration.id)
            assert_not_equal registration.owner_id, owner.id
          end
        end #put update
      end #edit actions
    end #CRUD actions

    context "lifecycle actions" do

      should "not perform an #register action" do
        assert_raise(ActiveRecord::AssociationTypeMismatch) do
          post :do_register, :registration => @registration_params
        end
      end

      should "not perform a #retract" do
        post :do_retract, :id => @registration.id
        assert_response :forbidden
      end

      should "not perform an #accept" do
        post :do_accept, :id => @registration.id
        assert_response :forbidden
      end

      should "not perform a #reject" do
        post :do_reject, :id => @registration.id
        assert_response :forbidden
      end

      should "not perform a #re-register" do
        post :do_re_register, :id => @registration.id
        assert_response :forbidden
      end
    end #lifecycle actions
  end #Guest

  context "User" do

    context "CRUD actions" do

      setup do
        user = Factory(:user)
        registration_role = Factory :registration_role
        country = Factory(:country)

        @registration = Factory(:registration, :owner=>user)

        assert_not_nil @registration.id

        @registration_params = {:registration_role_id => registration_role.id}

        login_as user
      end

      teardown do
        logout
      end

      context "write actions" do

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :registration => @registration_params
          end
        end

        should "not delete" do
          assert_raise(ActionController::UnknownAction) do
            delete :destroy, :id=>@registration.id
          end
        end
      end #write actions

      context "edit actions" do

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @registration.id
          assert_response :success
        end

        context "put update" do

          context "when state is #requested" do

            setup do
              @registration.state = 'requested'
              @registration.save
            end

            should "succeed for #registration_role" do
              registration_role = Factory :registration_role
              put :update, :id=>@registration.id, :registration => {:registration_role_id=>registration_role.id}
              assert_response :found

              registration = Registration.find(@registration.id)
              assert_equal registration.registration_role_id, registration_role.id
            end

          end #when state is #requested

          context "when state is #accepted" do

            setup do
              @registration.state = 'accepted'
              @registration.save
            end

            should "fail for #registration_role" do
              registration_role = Factory :registration_role
              put :update, :id=>@registration.id, :registration => {:registration_role_id=>registration_role.id}
              assert_response :forbidden

              registration = Registration.find(@registration.id)
              assert_not_equal registration.registration_role_id, registration_role.id
            end

          end #when state is #accepted

          context "when state is #rejected" do

            setup do
              @registration.state = 'rejected'
              @registration.save
            end

            should "succeed for #registration_role" do
              registration_role = Factory :registration_role
              put :update, :id=>@registration.id, :registration => {:registration_role_id=>registration_role.id}
              assert_response :found

              registration = Registration.find(@registration.id)
              assert_equal registration.registration_role_id, registration_role.id
            end

          end #when state is #rejected

          context "when state is #retracted" do

            setup do
              @registration.state = 'requested'
              @registration.save
            end

            should "succeed for #registration_role" do
              registration_role = Factory :registration_role
              put :update, :id=>@registration.id, :registration => {:registration_role_id=>registration_role.id}
              assert_response :found

              registration = Registration.find(@registration.id)
              assert_equal registration.registration_role_id, registration_role.id
            end

          end #when state is #retracted

          should "fail for #owner" do
            owner = Factory(:user)
            put :update, :id=>@registration.id, :registration => {:owner_id=>owner.id}
            assert_response :forbidden

            registration = Registration.find(@registration.id)
            assert_not_equal registration.owner_id, owner.id
          end
        end #put update
      end #edit actions
    end #CRUD actions

    context "lifecycle actions" do

      setup do
        user = Factory(:user)
	registration_role = Factory(:registration_role)

        @registration_params = {:registration_role_id => registration_role.id}

        login_as user

        post :do_register, :registration => @registration_params
        assert_response :found
      end

      teardown do
        logout
      end

      should "successfully perform a #register" do
        registration = Registration.find(:first, :conditions=>@registration_params)
        assert_not_nil registration
        assert_not_nil registration.id

        assert_not_nil registration.registration_role
        assert_equal registration.registration_role_id, @registration_params[:registration_role_id]

        assert_equal 'requested', registration.state
      end

      should "successfully perform a #retract" do
        registration = Registration.find(:first, :conditions=>@registration_params)

        post :do_retract, :id => registration.id
        assert_response :found

        registration = Registration.find(registration.id)
        assert_equal 'retracted', registration.state
      end

      should "not perform an #accept" do
        registration = Registration.find(:first, :conditions=>@registration_params)

        post :do_accept, :id => registration.id
        assert_response :forbidden

        registration = Registration.find(registration.id)
        assert_not_equal 'accepted', registration.state
      end

      should "not perform a #reject" do
        registration = Registration.find(:first, :conditions=>@registration_params)

        post :do_reject, :id => registration.id
        assert_response :forbidden

        registration = Registration.find(registration.id)
        assert_not_equal 'rejected', registration.state
      end

      context "when state is #retracted or #rejected" do

        should "successfully perform a re-register" do

          ['rejected', 'retracted'].each do |state|
            registration = Registration.find(:first, :conditions=>@registration_params)
            registration.state = "#{state}"
            registration.save!

            post :do_re_register, :id=>registration.id
            assert_response :found

            registration = Registration.find(registration.id)
            assert_equal registration.state, 'requested'
          end
        end #successfully perform a re-register
      end #when state is #retracted or #rejected
    end #registration lifecycle actions

    context "lifecycle actions for enrollment" do

      setup do
        @user = Factory(:user)
	registration_role = Factory(:registration_role, :operation => RegistrationRole::OperationType::ENROLLMENT)
        @registration_params = {:registration_role_id => registration_role.id}
        login_as @user
      end

      teardown do
        logout
      end

      should "successfully get a redirect for #register" do
        post :do_register, :registration => @registration_params
        assert_redirected_to :controller => :enrollments,
	                     :action => :enroll,
                             :enrollment=>{:registration_role_id =>
	                        @registration_params[:registration_role_id]}
      end

      context "with a country" do

	setup do
	  Factory :user_profile, :owner => @user
	end
      
	should "successfully get a redirect for #register with country" do
	  post :do_register, :registration => @registration_params
	  assert_redirected_to :controller => :enrollments,
			      :action => :enroll,
                             :enrollment=>{:registration_role_id =>
	                        @registration_params[:registration_role_id],
				:country_id => @user.country.id}
	end
      end
    end # enrollment registration lifecycle actions
  end #User

  context "Organization Admin" do

    setup do
      user = Factory(:user)

      @registration = Factory(:registration, :owner=>user)
      admin_role = Factory(:user)
      org = @registration.organization
      org.organization_admins = [admin_role]
      org.save!

      login_as admin_role
    end

    teardown do
      logout
    end

    context "CRUD actions" do

      context "write actions" do

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :registration => @registration_params
          end
        end

        should "not delete" do
          assert_raise(ActionController::UnknownAction) do
            delete :destroy, :id=>@registration.id
          end
        end
      end #write actions

      context "edit actions" do

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @registration.id
          assert_response :success
        end

      end #edit actions
    end #CRUD actions

    context "lifecycle actions" do

      should "perform an #accept" do
        post :do_accept, :id => @registration.id
        assert_response :found

        registration = Registration.find(@registration.id)
        assert_equal 'accepted', registration.state
      end

      should "perform a #reject" do
        post :do_reject, :id => @registration.id
        assert_response :found

        registration = Registration.find(@registration.id)
        assert_equal 'rejected', registration.state
      end
    end #registration lifecycle actions
  end #Organization Admin
end