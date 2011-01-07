require File.dirname(__FILE__) + '/../test_helper'

class EnrollmentTest < ActiveSupport::TestCase

  context "ActiveRecord" do

    context "validations" do
      should validate_presence_of :owner
      should validate_presence_of :event
      should validate_presence_of :boat
      should validate_presence_of :crew
      should validate_presence_of :country
    end

    context "relations" do
      should belong_to :owner
      should belong_to :event
      should belong_to :boat
      should belong_to :crew
      should belong_to :country
    end
  end #ActiveRecord

  context "Lifecycle" do
    
    should "have #enroll action" do
      assert Enrollment::Lifecycle.respond_to? :enroll
    end

    context "#enroll action" do

      setup do
        
        UserMailer.stubs(:deliver_event_enrollment_rejected)
        UserMailer.stubs(:deliver_event_enrollment_accepted)

        @user = Factory(:user)
        @org_admin = Factory(:user)

        @boat = Factory(:boat, :owner=>@user)
        @crew = Factory(:crew, :owner=>@user)
        @event = Factory(:event)

        org = @event.organization
        org.organization_admins = [@org_admin]
        org.save!

        @country = Factory(:country)

        enrollment_params = {:event=>@event, :boat=>@boat, :crew=>@crew, :country=>@country}
        @enrollment = Enrollment::Lifecycle.enroll(@user, enrollment_params)
      end

      should "create an enrollment" do
        assert_not_nil @enrollment
        assert_not_nil @enrollment.id

        assert_equal @event, @enrollment.event
        assert_equal @crew, @enrollment.crew
        assert_equal @boat, @enrollment.boat
        assert_equal @country, @enrollment.country
      end

      should "set the state to #requested" do
        assert_equal 'requested', @enrollment.state
      end

      should "set the correct ownership" do
        assert_equal @user, @enrollment.owner
      end

      context "#accept transition" do

        setup do
          @enrollment.lifecycle.accept! @org_admin
        end

        should "set the state to #accepted" do
          assert_equal 'accepted', @enrollment.state
        end
      end #accept transition

      context "#reject transition for #user" do

        setup do
          @enrollment.lifecycle.reject! @user
        end

        should "not set the state to #rejected" do
          assert_not_equal 'rejected', @enrollment.state
        end
      end #reject transition for #user
      
      context "#reject transition for #org_admin" do

        setup do
          @enrollment.lifecycle.reject! @org_admin
        end

        should "set the state to #rejected" do
          assert_equal 'rejected', @enrollment.state
        end
        
        should "allow a user to #re_enroll" do
          @enrollment.lifecycle.re_enroll! @user
          assert_equal 'requested', @enrollment.state
        end
      end #reject transition for #org_admin
    end #Lifecycle
  end #enroll action

  context "An enrollment" do
    setup {@enrollment = Factory(:enrollment)}
    subject {@enrollment}
    should "have the same owner with its children" do
      assert_equal subject.owner_id, subject.boat.owner_id
      assert_equal subject.owner_id, subject.crew.owner_id
    end
  end  
end