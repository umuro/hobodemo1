require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  context "ActiveRecord" do

    setup do
      @user = Factory(:user)
    end

    context "fields" do
      should have_db_column(:email_address).of_type(:string)
      should have_db_column(:administrator).of_type(:boolean).with_options(:default=>false)
    end

    context "validations" do
      should validate_uniqueness_of(:email_address)
    end

    context "relations" do
      should have_many(:organization_admin_roles).dependent(:destroy)
      should have_many(:organizations_as_admin).through(:organization_admin_roles)
      
      should have_many(:event_spotter_roles).dependent(:destroy)
      should have_many(:events_as_spotter).through(:event_spotter_roles)

      should have_many(:user_profiles).dependent(:destroy)
      should have_many(:boats).dependent(:destroy)
      should have_many(:crew_memberships).dependent(:destroy)
      
      should have_many(:joined_crew_memberships).dependent(:destroy)
      should have_many(:joined_crews).through(:joined_crew_memberships)
    end

  end

  context "Lifecycle" do

    should "have #signup and #invite actions" do
      [:invite, :signup].each do |m|
        assert User::Lifecycle.respond_to? m
      end
    end
  end

  context "A Guest" do
    
    setup do
      
      UserMailer.stubs(:deliver_signup_activation)
      
      @guest = Guest.new
      @signup_params = {:email_address => 'name@domain.com'}
    end

    context "with no key" do

      should "be able to signup" do
        assert_nil User.find_by_email_address @signup_params[:email_address]
        user = User::Lifecycle.signup(@guest, @signup_params)
        assert_not_nil user
        assert_equal @signup_params[:email_address], user.email_address
        assert_equal 'signed_up', user.state
      end
    end
  end
  
  context "A User" do

    setup do
      @user = Factory(:user)
    end

    subject { @user }

    should "have proper etag" do
      assert_equal subject.class.name, subject.etag[:klass]
      assert_equal subject.id, subject.etag[:id]
      assert_equal subject.updated_at.utc.tv_sec, subject.etag[:mtime]
    end

    should "repond to #user_profile and #user_profile=" do
      ['user_profile', 'user_profile='].each do |m|
        assert subject.respond_to? m
      end
    end
    
    context "as a spotter" do
      setup do
        @event_spotter_role = Factory :event_spotter_role, :user => @user
        @event = @event_spotter_role.event
      end
      
      subject { @event }
      
      # For some kindof odd reason, Delorean is not resetting Time.zone.now.utc where it is used on named_scopes
      # and/or conditions. Perhaps these are initialize beforehand
      #
      # These tests are as thus done by manipulating the event itself
      
      should "when time has not passed see the event" do
        subject.end_time = Time.now.in_time_zone(subject.event_tz) + 1.days
        subject.save!
        assert_not_nil @user.events_as_spotter.find(subject.id)
      end
      
      should "when time has passed not see the event" do
        subject.end_time = Time.now.in_time_zone(subject.event_tz) - 1.minutes
        subject.save!
        assert_raise(ActiveRecord::RecordNotFound) { @user.events_as_spotter.find(subject.id) }
      end
    end

    should "be deletable" do
      assert subject.destroy
    end
    
    should "have a PERSON crew" do
      pc = subject.crews.all :conditions => {:crew_type => Crew::Type::PERSON}
      assert_equal 1, pc.size
    end

    context "with an organization, " do

      setup do 
        @organization = Factory(:organization)
      end

      should "admin organization" do
        @organization.organization_admins << @user
        @organization.save
        assert @user.organization_admin?( @organization )
      end
    end

    context "with state #active" do

      setup do
        @user = Factory(:user, :state => 'active')
        @signup_params = {:email_address => @user.email_address}
      end

      should "not be able to signup again" do
        new_user = User::Lifecycle.signup(Guest.new, @signup_params)
        assert_nil new_user.id
        assert_not_nil @user.id
        assert_not_nil User.find(@user.id)
      end
    end #with state #active

    context "with state #signed_up" do

      setup do

        UserMailer.stubs(:deliver_signup_activation)

        @activation_params = {:password => 'pass', :password_confirmation => 'pass'}

        @signup_params = {:email_address => 'name@domain.com'}
        @user = User::Lifecycle.signup(Guest.new, @signup_params)
      end

      context "signing up again" do

        setup do
          @new_user = User::Lifecycle.signup(Guest.new, @signup_params)
        end

        should "remove the old user 'place holder'" do
          assert_equal false, User.exists?(@user)
        end

        should "create a new user 'place holder'" do
          assert_equal true, User.exists?(@new_user)
        end
      end #signing up again
      
      context "having the wrong key" do

        setup do
          @key = '1234567890'
        end

        should "not be able to activate his signup" do
          user = User.find_by_email_address @signup_params[:email_address]
          assert_not_nil user
          assert_equal 'signed_up', user.state

          user.lifecycle.provided_key = @key
          user.lifecycle.activate_signup!(@key, @activation_params)

          user = User.find(user.id)
          assert_equal 'signed_up', user.state
        end
      end

      context "having the right key" do

        setup do
          @key = @user.lifecycle.key
        end

        should "be able to activate his signup" do
          user = User.find_by_email_address @signup_params[:email_address]
          assert_not_nil user
          assert_equal 'signed_up', user.state

          user.lifecycle.provided_key = @key
          user.lifecycle.activate_signup!(@key, @activation_params)

          user = User.find(user.id)
          assert_equal 'active', user.state
        end
      end
    end
    
  end

  context "An admin" do

    setup do
      @admin = Factory(:admin)
    end

    should "admin organization" do
      assert @admin.organization_admin?( @organization )
    end
  end

end
