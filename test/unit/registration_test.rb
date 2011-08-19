require File.dirname(__FILE__) + '/../test_helper'

class RegistrationTest < ActiveSupport::TestCase

  context "ActiveRecord" do
    setup { Factory :registration }

    context "validations" do
      should validate_presence_of :owner
      # FIXME: should validate_presence_of :registration_role
    end

    context "relations" do
      should belong_to :owner
      should belong_to :registration_role
    end
  end #ActiveRecord
  context "Lifecycle" do

    should "have #register action" do
      assert Registration::Lifecycle.respond_to? :register
    end

    context "#register action" do

      setup do

        UserMailer.stubs(:deliver_event_abstract_registration_rejected)
        UserMailer.stubs(:deliver_event_abstract_registration_accepted)

        @user = Factory(:user)
        @org_admin = Factory(:user)

	@rr = Factory :registration_role

        org = @rr.organization
        org.organization_admins = [@org_admin]
        org.save!

        registration_params = {:registration_role=>@rr}
        @registration = Registration::Lifecycle.register(@user, registration_params)
      end

      should "create an registration" do
        assert_not_nil @registration
        assert_not_nil @registration.id
	assert_equal @rr, @registration.registration_role
      end

      should "set the state to #requested" do
        assert_equal 'requested', @registration.state
      end

      should "set the correct ownership" do
        assert_equal @user, @registration.owner
      end

      context "#accept transition" do

        setup do
          @registration.lifecycle.accept! @org_admin
        end

        should "set the state to #accepted" do
          assert_equal 'accepted', @registration.state
        end

        context "#cancel transition" do
          setup do
            @registration.lifecycle.cancel! @org_admin
          end

          should "set the state to #requested" do
            assert_equal 'requested', @registration.state
          end
        end
      end #accept transition

      context "#reject transition for #user" do

        setup do
          @registration.lifecycle.reject! @user
        end

        should "not set the state to #rejected" do
          assert_not_equal 'rejected', @registration.state
        end
      end #reject transition for #user

      context "#reject transition for #org_admin" do

        setup do
          @registration.lifecycle.reject! @org_admin
        end

        should "set the state to #rejected" do
          assert_equal 'rejected', @registration.state
        end

        should "allow a user to #re_enroll" do
          @registration.lifecycle.re_register! @user
          assert_equal 'requested', @registration.state
        end
      end #reject transition for #org_admin
    end #Lifecycle
  end #register action

end
