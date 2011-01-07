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

class EnrollmentsControllerTest < ActionController::TestCase

  context "Guest" do

    setup do
      user = Factory(:user)
      boat = Factory(:boat, :owner => user)
      crew = Factory(:crew, :owner => user)
      event = Factory(:event)
      country = Factory(:country)

      @enrollment = Factory(:enrollment, :owner=>user, :boat=>boat, 
                            :crew=>crew, :country=>country)
      assert_not_nil @enrollment.id

      @enrollment_params = {:event_id => event.id, :boat_id => boat.id, 
                            :crew_id => crew.id, :country_id => country.id}
    end

    context "CRUD actions" do

      context "write actions" do

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do 
            post :create, :enrollment => @enrollment_params 
          end
        end

        should "not delete" do
          assert_raise(ActionController::UnknownAction) do
            delete :destroy, :id=>@enrollment.id            
          end
        end
      end #write actions

      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @enrollment.id
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
          get :edit, :id => @enrollment.id
          assert_response :success
        end

        context "put update" do

          should "fail for #insured" do
            put :update, :id=>@enrollment.id, :enrollment => {:insured=>true}
            assert_response :forbidden
            
            enrollment = Enrollment.find(@enrollment.id)
            assert_equal false, enrollment.insured
          end

          should "fail for #measured" do
            put :update, :id=>@enrollment.id, :enrollment => {:measured=>true}
            assert_response :forbidden
            
            enrollment = Enrollment.find(@enrollment.id)
            assert_equal false, enrollment.measured
          end
          
          should "fail for #paid" do
            put :update, :id=>@enrollment.id, :enrollment => {:paid=>true}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_equal false, enrollment.paid
          end

          should "fail for #country" do
            country = Factory(:country)
            
            put :update, :id=>@enrollment.id, :enrollment => {:country_id=>country.id}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_not_equal enrollment.country_id, country.id
          end

          should "fail for #event" do
            event = Factory(:event)
            put :update, :id=>@enrollment.id, :enrollment => {:event_id=>event.id}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_not_equal enrollment.event_id, event.id
          end

          should "fail for #boat" do
            boat = Factory(:boat, :owner=>@enrollment.owner)
            put :update, :id=>@enrollment.id, :enrollment => {:boat_id=>boat.id}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_not_equal enrollment.boat_id, boat.id
          end

          should "fail for #crew" do
            crew = Factory(:crew, :owner=>@enrollment.owner)
            put :update, :id=>@enrollment.id, :enrollment => {:crew_id=>crew.id}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_not_equal enrollment.crew_id, crew.id
          end

          should "fail for #owner" do
            owner = Factory(:user)
            put :update, :id=>@enrollment.id, :enrollment => {:owner_id=>owner.id}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_not_equal enrollment.owner_id, owner.id
          end
        end #put update
      end #edit actions
    end #CRUD actions

    context "lifecycle actions" do

      should "not perform an #enroll action" do
        assert_raise(ActiveRecord::AssociationTypeMismatch) do
          post :do_enroll, :enrollment => @enrollment_params
        end
      end

      should "not perform a #retract" do
        post :do_retract, :id => @enrollment.id
        assert_response :forbidden
      end

      should "not perform an #accept" do        
        post :do_accept, :id => @enrollment.id
        assert_response :forbidden
      end

      should "not perform a #reject" do
        post :do_reject, :id => @enrollment.id
        assert_response :forbidden
      end
      
      should "not perform a #re-enroll" do
        post :do_re_enroll, :id => @enrollment.id
        assert_response :forbidden
      end
    end #lifecycle actions
  end #Guest

  context "User" do

    context "CRUD actions" do

      setup do
        user = Factory(:user)
        boat = Factory(:boat, :owner => user)
        crew = Factory(:crew, :owner => user)
        event = Factory(:event)
        country = Factory(:country)

        @enrollment = Factory(:enrollment, :owner=>user, :boat=>boat, 
                              :crew=>crew, :country=>country)

        assert_not_nil @enrollment.id

        @enrollment_params = {:event_id => event.id, :boat_id => boat.id, 
                              :crew_id => crew.id, :country_id => country.id}

        login_as user
      end

      teardown do
        logout
      end
      
      context "write actions" do

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do 
            post :create, :enrollment => @enrollment_params 
          end
        end

        should "not delete" do
          assert_raise(ActionController::UnknownAction) do
            delete :destroy, :id=>@enrollment.id            
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
          get :edit, :id => @enrollment.id
          assert_response :success
        end

        context "put update" do

          context "when state is #requested" do

            setup do
              @enrollment.state = 'requested'
              @enrollment.save
            end

            should "succeed for #event" do
              event = Factory(:event)
              put :update, :id=>@enrollment.id, :enrollment => {:event_id=>event.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.event_id, event.id
            end

            should "succeed for #boat" do
              boat = Factory(:boat, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:boat_id=>boat.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.boat_id, boat.id
            end

            should "succeed for #crew" do
              crew = Factory(:crew, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:crew_id=>crew.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.crew_id, crew.id
            end

            should "succeed for #country" do
              country = Factory(:country)

              put :update, :id=>@enrollment.id, :enrollment => {:country_id=>country.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.country_id, country.id
            end
          end #when state is #requested

          context "when state is #accepted" do

            setup do
              @enrollment.state = 'accepted'
              @enrollment.save
            end

            should "fail for #event" do
              event = Factory(:event)
              put :update, :id=>@enrollment.id, :enrollment => {:event_id=>event.id}
              assert_response :forbidden

              enrollment = Enrollment.find(@enrollment.id)
              assert_not_equal enrollment.event_id, event.id
            end

            should "fail for #boat" do
              boat = Factory(:boat, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:boat_id=>boat.id}
              assert_response :forbidden

              enrollment = Enrollment.find(@enrollment.id)
              assert_not_equal enrollment.boat_id, boat.id
            end

            should "fail for #crew" do
              crew = Factory(:crew, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:crew_id=>crew.id}
              assert_response :forbidden

              enrollment = Enrollment.find(@enrollment.id)
              assert_not_equal enrollment.crew_id, crew.id
            end
            
            should "fail for #country" do
              country = Factory(:country)

              put :update, :id=>@enrollment.id, :enrollment => {:country_id=>country.id}
              assert_response :forbidden

              enrollment = Enrollment.find(@enrollment.id)
              assert_not_equal enrollment.country_id, country.id
            end
          end #when state is #accepted

          context "when state is #rejected" do
            
            setup do
              @enrollment.state = 'rejected'
              @enrollment.save
            end

            should "succeed for #event" do
              event = Factory(:event)
              put :update, :id=>@enrollment.id, :enrollment => {:event_id=>event.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.event_id, event.id
            end

            should "succeed for #boat" do
              boat = Factory(:boat, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:boat_id=>boat.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.boat_id, boat.id
            end

            should "succeed for #crew" do
              crew = Factory(:crew, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:crew_id=>crew.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.crew_id, crew.id
            end
          end #when state is #rejected

          context "when state is #retracted" do
            
            setup do
              @enrollment.state = 'requested'
              @enrollment.save
            end

            should "succeed for #event" do
              event = Factory(:event)
              put :update, :id=>@enrollment.id, :enrollment => {:event_id=>event.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.event_id, event.id
            end

            should "succeed for #boat" do
              boat = Factory(:boat, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:boat_id=>boat.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.boat_id, boat.id
            end

            should "succeed for #crew" do
              crew = Factory(:crew, :owner=>@enrollment.owner)
              put :update, :id=>@enrollment.id, :enrollment => {:crew_id=>crew.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.crew_id, crew.id
            end
            
            should "succeed for #country" do
              country = Factory(:country)

              put :update, :id=>@enrollment.id, :enrollment => {:country_id=>country.id}
              assert_response :found

              enrollment = Enrollment.find(@enrollment.id)
              assert_equal enrollment.country_id, country.id
            end
          end #when state is #retracted

          should "fail for #insured" do
            put :update, :id=>@enrollment.id, :enrollment => {:insured=>true}
            assert_response :forbidden
            
            enrollment = Enrollment.find(@enrollment.id)
            assert_equal false, enrollment.insured
          end

          should "fail for #measured" do
            put :update, :id=>@enrollment.id, :enrollment => {:measured=>true}
            assert_response :forbidden
            
            enrollment = Enrollment.find(@enrollment.id)
            assert_equal false, enrollment.measured
          end

          should "fail for #paid" do
            put :update, :id=>@enrollment.id, :enrollment => {:paid=>true}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_equal false, enrollment.paid
          end

          should "fail for #owner" do
            owner = Factory(:user)
            put :update, :id=>@enrollment.id, :enrollment => {:owner_id=>owner.id}
            assert_response :forbidden

            enrollment = Enrollment.find(@enrollment.id)
            assert_not_equal enrollment.owner_id, owner.id
          end
        end #put update
      end #edit actions
    end #CRUD actions

    context "lifecycle actions" do

      setup do
        user = Factory(:user)
        boat = Factory(:boat, :owner => user)
        crew = Factory(:crew, :owner => user)
        event = Factory(:event)
        country = Factory(:country)

        @enrollment_params = {:event_id => event.id, :boat_id => boat.id, 
                              :crew_id => crew.id, :country_id => country.id}

        login_as user

        post :do_enroll, :enrollment => @enrollment_params
        assert_response :found
      end

      teardown do
        logout
      end

      should "successfully perform an #enroll" do
        enrollment = Enrollment.find(:first, :conditions=>@enrollment_params)
        assert_not_nil enrollment
        assert_not_nil enrollment.id

        assert_not_nil enrollment.event
        assert_equal enrollment.event_id, @enrollment_params[:event_id]

        assert_not_nil enrollment.boat
        assert_equal enrollment.boat_id, @enrollment_params[:boat_id]

        assert_not_nil enrollment.crew
        assert_equal enrollment.crew_id, @enrollment_params[:crew_id]

        assert_not_nil enrollment.country
        assert_equal enrollment.country_id, @enrollment_params[:country_id]

        assert_equal 'requested', enrollment.state
      end
 
      should "successfully perform a #retract" do
        enrollment = Enrollment.find(:first, :conditions=>@enrollment_params)

        post :do_retract, :id => enrollment.id
        assert_response :found

        enrollment = Enrollment.find(enrollment.id)
        assert_equal 'retracted', enrollment.state
      end

      should "not perform an #accept" do        
        enrollment = Enrollment.find(:first, :conditions=>@enrollment_params)

        post :do_accept, :id => enrollment.id
        assert_response :forbidden

        enrollment = Enrollment.find(enrollment.id)
        assert_not_equal 'accepted', enrollment.state
      end

      should "not perform a #reject" do
        enrollment = Enrollment.find(:first, :conditions=>@enrollment_params)

        post :do_reject, :id => enrollment.id
        assert_response :forbidden

        enrollment = Enrollment.find(enrollment.id)
        assert_not_equal 'rejected', enrollment.state
      end

      context "when state is #retracted or #rejected" do

        should "successfully perform a re-enroll" do
          
          ['rejected', 'retracted'].each do |state|
            enrollment = Enrollment.find(:first, :conditions=>@enrollment_params)
            enrollment.state = "#{state}"
            enrollment.save!

            post :do_re_enroll, :id=>enrollment.id
            assert_response :found

            enrollment = Enrollment.find(enrollment.id)
            assert_equal enrollment.state, 'requested'
          end
        end #successfully perform a re-enroll
      end #when state is #retracted or #rejected
    end #enrollment lifecycle actions
  end #User

  context "Organization Admin" do

    setup do
      user = Factory(:user)
      boat = Factory(:boat, :owner => user)
      crew = Factory(:crew, :owner => user)

      @enrollment = Factory(:enrollment, :owner=>user, :boat=>boat, :crew=>crew)
      admin_role = Factory(:user)
      org = @enrollment.organization
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
            post :create, :enrollment => @enrollment_params 
          end
        end

        should "not delete" do
          assert_raise(ActionController::UnknownAction) do
            delete :destroy, :id=>@enrollment.id            
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
          get :edit, :id => @enrollment.id
          assert_response :success
        end

        context "put update" do

          should "succeed for #insured" do
            put :update, :id=>@enrollment.id, :enrollment => {:insured=>true}
            assert_response :found
            
            enrollment = Enrollment.find(@enrollment.id)
            assert_equal true, enrollment.insured
          end

          should "succeed for #measured" do
            put :update, :id=>@enrollment.id, :enrollment => {:measured=>true}
            assert_response :found
            
            enrollment = Enrollment.find(@enrollment.id)
            assert_equal true, enrollment.measured
          end
          
          should "succeed for #paid" do
            put :update, :id=>@enrollment.id, :enrollment => {:paid=>true}
            assert_response :found

            enrollment = Enrollment.find(@enrollment.id)
            assert_equal true, enrollment.paid
          end
        end #update
      end #edit actions
    end #CRUD actions

    context "lifecycle actions" do

      should "perform an #accept" do
        post :do_accept, :id => @enrollment.id
        assert_response :found
        
        enrollment = Enrollment.find(@enrollment.id)
        assert_equal 'accepted', enrollment.state
      end

      should "perform a #reject" do
        post :do_reject, :id => @enrollment.id
        assert_response :found

        enrollment = Enrollment.find(@enrollment.id)
        assert_equal 'rejected', enrollment.state
      end
    end #enrollment lifecycle actions
  end #Organization Admin
end