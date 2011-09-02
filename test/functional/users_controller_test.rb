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
      @user = Factory(:user_profile).owner
      @attrs = Factory.attributes_for(:user) 
    }

    context "Guest" do
      #setup {login_as somebody}
      context "(read_actions)" do

        should "get index" do
          get :index
          assert_response :success
        end

        should "get show" do
          get :show, :id=>@user.id
	  #FIXME... Only admins can see profiles on enrolled users
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

        should "not create invitations" do
          get :invite
          assert_response :forbidden
        end
      end
    end
  end

  context "Admin" do

    setup do
      @admin = Factory(:admin)
      login_as @admin
    end

    teardown do
      logout
    end
    
    context "active user account" do

      setup do
        @user = Factory(:user, :state=> 'active')
      end

      should "be able to inactivate the account" do
        assert_equal 'active', @user.state
        put :do_inactivate_account, :id => @user.id
        assert_response :found
        user = User.find(@user.id)
        assert_equal 'inactive', user.state
      end
    end #active user account

    context "inactive user account" do
      
      setup do
        @user = Factory(:user, :state=> 'inactive')
      end

      should "be able to activate the account" do
        assert_equal 'inactive', @user.state
        put :do_activate_account, :id => @user.id
        assert_response :found
        user = User.find(@user.id)
        assert_equal 'active', user.state
      end
    end #inactive user account
  end #Admin

  context "Guest" do

    setup do
      @email_address = 'name@domain.com'
    end

    context "new user" do

      should "be able to signup" do
        post :do_signup, :user =>{:email_address => @email_address}
        assert_response :found
        new_user = User.find_by_email_address(@email_address)
        assert_not_nil new_user
        assert_equal 'signed_up', new_user.state
      end
    end #new user

    context "account actions" do
     
      context "an active user account" do

        setup do
          @user = Factory(:user, :state=> 'active')
        end

        should "not be able to inactivate the account" do
          assert_equal 'active', @user.state
          put :do_inactivate_account, :id => @user.id
          assert_response :forbidden
          user = User.find(@user.id)
          assert_equal 'active', user.state
        end
      end #active user account

      context "an inactive user account" do

        setup do
          @user = Factory(:user, :state=> 'inactive')
        end

        should "not be able to activate the account" do
          assert_equal 'inactive', @user.state
          put :do_activate_account, :id => @user.id
          assert_response :forbidden
          user = User.find(@user.id)
          assert_equal 'inactive', user.state
        end
      end #inactive user account
    end #account actions
  end #Guest

# Mobile client auth
  context "Existing mobile client user wanting to authenticate himself" do

    setup do
      @user = Factory.create :user
#       @guest = Factory.build :guest
      @wronguser = "wronguserzzzz"
      @wrongpass = "wrongpasszzzz"
    end

    context "using bad password" do
      should "fail, returning :success with <login>guest</login>" do
        post :login_xml, :format => 'xml', :params => {:login => @user.email_address, :password => @wrongpass }
        assert_response :unauthorized 
      end
    end

    context "using bad username" do
      should "fail, returning :success with <login>guest</login>" do
        post :login_xml, :format => 'xml', :params => {:login => @wronguser, :password => @user.password }
        assert_response :unauthorized 
      end
    end

    context "using correct username/password pair" do
      should "succeed, returning :success with @user" do
        post :login_xml, :format => 'xml', :params => {:login => @user.email_address, :password => @user.password}
        assert_response :success
        assert_tag :tag => "login", :child => { :content => @user.email_address }
        assert_not_nil @request.session[:user]
      end
    end

  end

  context "Existing & authenticated mobile client user wants to de-auth" do

    setup do
      @user = Factory.create(:user_profile).owner
      login_as @user
    end

    should "sucessful" do
      get :logout_xml, :format => 'xml'
      assert_response :success
      assert_tag :tag => "logout"
      assert_nil @request.session[:user]
    end 

  end

end
