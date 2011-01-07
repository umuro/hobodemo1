require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

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

# Mobile Client

class CoursesControllerTest < ActionController::TestCase

  context "Guest" do

    setup do
      @organization = Factory(:organization)
      @course = Factory(:course)
      @course_params = {:name => 'Snake', :organization_id => @course.organization_id}
    end

    context "CRUD actions" do

      context "write actions" do

        should "not post create_for_organization" do
          post :create_for_organization, :organization_id => @course.organization_id, :course => @course_params
          assert_response :forbidden

          c = Course.find_by_name(@course_params[:name])
          assert c.nil?
        end

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :course=>@course_params
          end
        end

        should "not delete" do
          delete :destroy, :id=>@course.id
          assert_response :forbidden
        end
      end #write actions
      
      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @course.id
          assert_response :success
        end
      end #read actions
      
      context "edit actions" do

        should "not get #new_for_organization" do
          get :new_for_organization, :organization_id=>@organization.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @course.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        context "put update" do

          should "fail for #name" do

            new_name = 'Tiger'
            put :update, :id=>@course.id, :course => {:name=>new_name}
            assert_response :forbidden
            
            course = Course.find(@course.id)
            assert_not_equal new_name, course.name
          end

          should "fail for #organization_id" do

            new_org = Factory(:organization)
            put :update, :id=>@course.id, :course => {:organization_id=>new_org.id}
            assert_response :forbidden

            course = Course.find(@course.id)
            assert_not_equal new_org.id, course.organization_id
          end
        end #put update
      end #edit actions
    end #CRUD actions
  end #Guest

  context "User" do

    setup do
      @course = Factory(:course)
      @course_params = {:name => 'Snake', :organization_id => @course.organization_id}
      
      org_admin = Factory(:user)
      @organization = Factory(:organization, :organization_admins=>[org_admin])

      user = Factory(:user)
      login_as user
    end

    teardown do
      logout
    end

    context "CRUD actions" do
    
      context "write actions" do

        should "not post create_for_organization" do
          post :create_for_organization, :organization_id => @course.organization_id, :course => @course_params
          assert_response :forbidden

          c = Course.find_by_name(@course_params[:name])
          assert c.nil?
        end
        
        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :course => @course_params
          end
        end

        should "not delete" do
          delete :destroy, :id=>@course.id
          assert_response :forbidden
        end
      end #write actions
      
      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @course.id
          assert_response :success
        end
      end #read actions
      
      context "edit actions" do

        should "not get #new_for_organization" do
          get :new_for_organization, :organization_id=>@organization.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end
        
        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @course.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        context "put update" do

          should "fail for #name" do

            new_name = 'Tiger'
            put :update, :id=>@course.id, :course => {:name=>new_name}
            assert_response :forbidden
            
            course = Course.find(@course.id)
            assert_not_equal new_name, course.name
          end
          
          should "fail for #organization_id" do

            new_org = Factory(:organization)
            put :update, :id=>@course.id, :course => {:organization_id=>new_org.id}
            assert_response :forbidden

            course = Course.find(@course.id)
            assert_not_equal new_org.id, course.organization_id
          end
        end #put update        
      end #edit actions
    end #CRUD actions
  end #User

  context "Organization Administrator" do

    setup do
      @admin = Factory(:user)
      
      @course = Factory(:course)
      @course.organization.organization_admins = [@admin]
      @course.save

      @organization = Factory(:organization, :organization_admins=>[@admin])

      @course_params = {:name => 'Snake', :organization_id => @organization.id}

      login_as @admin
    end

    teardown do
      logout
    end

    context "CRUD actions" do

      context "write actions" do

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :course => @course_params
          end
        end

        should "post create_for_organization" do
          post :create_for_organization, :organization_id => @organization.id, :course => @course_params
          assert_response :found

          c = Course.find_by_name(@course_params[:name])
          assert_not_nil c
          assert_equal @course_params[:organization_id], c.organization_id
          assert_equal @course_params[:name], c.name
        end

        should "delete" do
          delete :destroy, :id=>@course.id
          assert_response :found

          assert_raise(ActiveRecord::RecordNotFound) do
            Course.find(@course.id)
          end
        end
      end #write actions
      
      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @course.id
          assert_response :success
        end
      end #read actions
      
      context "edit actions" do

        should "get #new_for_organization" do
          get :new_for_organization, :organization_id=>@organization.id
          assert_response :success
          assert_tag :tag => 'form'
        end

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @course.id
          assert_response :success
          assert_tag :tag => 'form'
        end
        
        context "put update" do

          should "succeed for #name" do

            new_name = 'Tiger'
            put :update, :id=>@course.id, :course => {:name=>new_name}
            assert_response :found

            course = Course.find(@course.id)
            assert_equal new_name, course.name
          end
          
          should "succeed for #organization_id" do

            new_org = Factory(:organization, :organization_admins=>[@admin])
            put :update, :id=>@course.id, :course => {:organization_id=>new_org.id}
            assert_response :found

            course = Course.find(@course.id)
            assert_equal new_org.id, course.organization_id
          end
        end #put update
      end #edit actions
    end #CRUD actions
  end #Organization Administrator
  
  context "in spotting Story, " do
   # Mobile Client
    setup do
      @the_spotter = Factory(:user)
#       Event.any_instance.stubs(:acting_user).returns(@the_spotter)
      @boat = UseCaseSamples.build_boat 
      @fleet_race = UseCaseSamples.build_fleet_race 
    end
    context "with a course, " do
      setup {@course=@fleet_race.course}
      should  "show" do
        get :show, :id => @course.id, :format=>'xml'
        assert_response :success
        klass = "Course"
        assert_tag :tag => 'name',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
#         assert_tag :tag => 'race_id',
#                               :parent => { :tag => klass.underscore },
#                               :content => /[0-9]+/
        assert_tag :tag => 'spots',
                              :parent => { :tag => klass.underscore }
        klass = "Spot"
        assert_tag :tag=>klass.underscore.pluralize,
            :descendant => { :tag => klass.underscore }
        assert_tag :tag => 'position',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
        assert_tag :tag => 'spot_type',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'name',
                              :parent => { :tag => klass.underscore },
                              :content => /.+/
        assert_tag :tag => 'id',
                              :parent => { :tag => klass.underscore },
                              :content => /[0-9]+/
      end #should
    end #context
   end #context
end
