require File.dirname(__FILE__) + '/../test_helper'

class SpotsControllerTest < ActionController::TestCase

  context "Spot(Security): " do
    setup do
      @template_course = Factory :template_course
      @spot = Factory :spot, :course => @template_course
      @spot_params = Factory.attributes_for(:spot, :course_id=>@spot.course.id, :position=>99)
    end

    context "Guest" do
      context "CRUD actions" do
        context "write actions" do

          should "not post create_for_course" do
            post :create_for_course, :course_id => @spot.course.id, :spot => @spot_params
            assert_response :forbidden

            c = Spot.find_by_position(@spot_params[:position])
            assert c.nil?
          end

          should "not post create" do
            assert_raise(ActionController::UnknownAction) do
              post :create, :spot=>@spot_params
            end
          end

          should "not put update" do
                  put :update, :id => @spot.id, :spot => @spot_params
                  assert_response :forbidden
          end

          should "not delete" do
            delete :destroy, :id=>@spot.id
            assert_response :forbidden
          end

        end #write actions
        
        context "read actions" do

          should "get index" do
            get :index
            assert_response :success
          end

          should "get show" do
            get :show, :id => @spot.id
            assert_response :success
          end
        end #read actions

        context "edit actions" do

          should "not get #new_for_course" do
            get :new_for_course, :course_id=>@spot.course.id
            assert_response :success
            assert_no_tag :tag => 'form'
          end

          should "not get new" do
            get :new
            assert_response :success
            assert_no_tag :tag => 'form'
          end

          should "get edit" do
            get :edit, :id => @spot.id
            assert_response :success
            assert_no_tag :tag => 'form'
          end

        end #edit actions
      end #CRUD actions
    end #Guest

    context "User" do
      setup do
        user = Factory(:user_profile).owner
        login_as user
      end

      teardown do
        logout
      end

      context "CRUD actions" do
        context "write actions" do
          should "not post create_for_course" do
            post :create_for_course, :course_id => @spot.course.id, :spot => @spot_params
            assert_response :forbidden

            c = Spot.find_by_position(@spot_params[:position])
            assert c.nil?
          end

          should "not post create" do
            assert_raise(ActionController::UnknownAction) do
              post :create, :spot=>@spot_params
            end
          end

          should "not put update" do
                  post :update, :id => @spot.id, :spot => @spot_params
                  assert_response :forbidden
          end

          should "not delete" do
            delete :destroy, :id=>@spot.id
            assert_response :forbidden
          end
        end #write actions
        
        context "read actions" do

          should "get index" do
            get :index
            assert_response :success
          end

          should "get show" do
            get :show, :id => @spot.id
            assert_response :success
          end
        end #read actions

        context "edit actions" do

          should "not get #new_for_course" do
            get :new_for_course, :course_id=>@spot.course.id
            assert_response :success
            assert_no_tag :tag => 'form'
          end

          should "not get new" do
            get :new
            assert_response :success
            assert_no_tag :tag => 'form'
          end

          should "get edit" do
            get :edit, :id => @spot.id
            assert_response :success
            assert_no_tag :tag => 'form'
          end
        end #edit actions
      end #CRUD actions
    end #User

    context "Organization Administrator" do
      setup do
        @admin = Factory(:user_profile).owner
        @spot.course.organization.organization_admins << @admin
        @spot.course.organization.save!; @admin.save!

        login_as @admin
      end

      teardown do
        logout
      end

      context "CRUD actions" do

        context "write actions" do

          should "not post #create" do
            assert_raise(ActionController::UnknownAction) do
              post :create, :course => @spot_params
            end
          end

          should "post #create_for_course" do
            
            post :create_for_course, :course_id => @spot.course.id, :spot => @spot_params
            assert_response :found

            spot = Spot.find_by_position(@spot_params[:position])
            assert_not_nil spot
            assert_equal @spot_params[:course_id], spot.course_id
            assert_equal @spot_params[:name], spot.attributes["name"]
          end

          should "not put update" do
                  put :update, :id => @spot.id, :spot => @spot_params
                  assert_response :forbidden
          end

          should "delete" do
            delete :destroy, :id=>@spot.id
            assert_response :found

            assert_raise(ActiveRecord::RecordNotFound) do
              Spot.find(@spot.id)
            end
          end
        end #write actions
        
        context "read actions" do

          should "get index" do
            get :index
            assert_response :success
          end

          should "get show" do
            get :show, :id => @spot.id
            assert_response :success
          end
        end #read actions
        
        context "edit actions" do

          should "get #new_for_organization" do
            get :new_for_course, :course_id=>@spot.course.id
            assert_response :success
            assert_tag :tag => 'form'
          end

          should "not get new" do
            get :new
            assert_response :success
            assert_no_tag :tag => 'form'
          end

          should "get edit" do
            get :edit, :id => @spot.id
            assert_response :success
            assert_tag :tag => 'form'
          end

        end #edit actions
      end #CRUD actions
    end #Organization Administrator

    context "Mobile Client" do

      setup do
        fleet_race = UseCaseSamples.build_fleet_race 
        @course_id = fleet_race.course.id
      end

      context "read actions" do

        should "return the spots of a course" do

          #GET http://host:port/courses/:id/spots.xml
          get :index_for_course, :course_id=>@course_id, :format=>:xml
          assert_response :success

          klass = "Spot"
          assert_tag :tag=>klass.underscore.pluralize,
                     :descendant => { :tag => klass.underscore }

          assert_tag :tag => 'position',
                     :parent => { :tag => klass.underscore },
                     :content => /[0-9]+/

          assert_tag :tag => 'spot_type',
                     :parent => { :tag => klass.underscore },
                     :content => /(:Report|:Finish|:OCS|:Mark)/
        end #return the spots of a course
      end #read actions
    end #Mobile Client
  end
end