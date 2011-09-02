require File.dirname(__FILE__) + '/../test_helper'

require File.dirname(__FILE__) + '/../test_helper'
require 'test/factories/use_case_samples'

class TemplateCoursesControllerTest < ActionController::TestCase

  context "Guest" do

    setup do
      @organization = Factory(:organization)
      @template_course = Factory(:template_course)
      @template_course_params = {:name => 'Snake', :organization_id => @template_course.organization_id}
    end

    context "CRUD actions" do

      context "write actions" do

        should "not post create_for_organization" do
          post :create_for_organization, :organization_id => @template_course.organization_id, :template_course => @template_course_params
          assert_response :forbidden

          c = TemplateCourse.find_by_name(@template_course_params[:name])
          assert_nil c
        end

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :template_course=>@template_course_params
          end
        end

        should "not delete" do
          delete :destroy, :id=>@template_course.id
          assert_response :forbidden
        end
      end #write actions
      
      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @template_course.id
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
          get :edit, :id => @template_course.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        context "put update" do

          should "fail for #name" do

            new_name = 'Tiger'
            put :update, :id=>@template_course.id, :template_course => {:name=>new_name}
            assert_response :forbidden
            
            course = Course.find(@template_course.id)
            assert_not_equal new_name, course.name
          end

          should "fail for #organization_id" do

            new_org = Factory(:organization)
            put :update, :id=>@template_course.id, :template_course => {:organization_id=>new_org.id}
            assert_response :forbidden

            course = Course.find(@template_course.id)
            assert_not_equal new_org.id, course.organization_id
          end
        end #put update
      end #edit actions
    end #CRUD actions
  end #Guest

  context "User" do

    setup do
      @template_course = Factory(:template_course)
      @template_course_params = {:name => 'Snake', :organization_id => @template_course.organization_id}
      
      org_admin = Factory(:user_profile).owner
      @organization = Factory(:organization, :organization_admins=>[org_admin])

      user = Factory(:user_profile).owner
      login_as user
    end

    teardown do
      logout
    end

    context "CRUD actions" do
    
      context "write actions" do

        should "not post create_for_organization" do
          post :create_for_organization, :organization_id => @template_course.organization_id, :template_course => @template_course_params
          assert_response :forbidden

          c = TemplateCourse.find_by_name(@template_course_params[:name])
          assert_nil c
        end
        
        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :template_course => @template_course_params
          end
        end

        should "not delete" do
          delete :destroy, :id=>@template_course.id
          assert_response :forbidden
        end
      end #write actions
      
      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @template_course.id
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
          get :edit, :id => @template_course.id
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        context "put update" do

          should "fail for #name" do

            new_name = 'Tiger'
            put :update, :id=>@template_course.id, :template_course => {:name=>new_name}
            assert_response :forbidden
            
            course = Course.find(@template_course.id)
            assert_not_equal new_name, course.name
          end
          
          should "fail for #organization_id" do

            new_org = Factory(:organization)
            put :update, :id=>@template_course.id, :template_course => {:organization_id=>new_org.id}
            assert_response :forbidden

            course = Course.find(@template_course.id)
            assert_not_equal new_org.id, course.organization_id
          end
        end #put update        
      end #edit actions
    end #CRUD actions
  end #User

  context "Organization Administrator" do

    setup do
      @admin = Factory(:user_profile).owner
      
      @template_course = Factory(:template_course)
      @template_course.organization.organization_admins = [@admin]
      @template_course.save

      @organization = Factory(:organization, :organization_admins=>[@admin])

      @template_course_params = {:name => 'Snake', :organization_id => @organization.id}

      login_as @admin
    end

    teardown do
      logout
    end

    context "CRUD actions" do

      context "write actions" do

        should "not post create" do
          assert_raise(ActionController::UnknownAction) do
            post :create, :template_course => @template_course_params
          end
        end

        # A redirect is send, it appears to be caused by STI
        should "post create_for_organization" do
          post :create_for_organization, :organization_id => @organization.id, :template_course => @template_course_params
          assert_response :redirect
        end

        should "delete" do
          delete :destroy, :id=>@template_course.id
          assert_response :found

          assert_raise(ActiveRecord::RecordNotFound) do
            Course.find(@template_course.id)
          end
        end
      end #write actions
      
      context "read actions" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id => @template_course.id
          assert_response :success
        end
      end #read actions
      
      context "edit actions" do

        should "get #new_for_organization" do
          get :new_for_organization, :organization_id=>@organization.id
          assert_response :success
        end

        should "not get new" do
          get :new
          assert_response :success
          assert_no_tag :tag => 'form'
        end

        should "get edit" do
          get :edit, :id => @template_course.id
          assert_response :success
          assert_tag :tag => 'form'
        end
        
        context "put update" do

          should "succeed for #name" do

            new_name = 'Tiger'
            put :update, :id=>@template_course.id, :template_course => {:name=>new_name}
            assert_response :found

            course = Course.find(@template_course.id)
            assert_equal new_name, course.name
          end
          
          should "succeed for #organization_id" do

            new_org = Factory(:organization, :organization_admins=>[@admin])
            put :update, :id=>@template_course.id, :template_course => {:organization_id=>new_org.id}
            assert_response :found

            course = Course.find(@template_course.id)
            assert_equal new_org.id, course.organization_id
          end
        end #put update
      end #edit actions
    end #CRUD actions
  end #Organization Administrator
  
  
end
