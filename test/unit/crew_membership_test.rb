require File.dirname(__FILE__) + '/../test_helper'

class CrewMembershipTest < ActiveSupport::TestCase

  context "ActiveRecord" do

    context "validations" do
      should validate_presence_of :joined_crew
      should validate_presence_of :invitee
    end

    context "relations" do
      should belong_to :joined_crew
      should belong_to :invitee
    end
    
    should "respond to invite lifecycle action" do
      assert CrewMembership::Lifecycle.respond_to? :invite
    end

  end

  context "A personal crew" do

    setup do

      UserMailer.stubs(:deliver_invite_user)
      UserMailer.stubs(:deliver_crew_membership_invitation)
      UserMailer.stubs(:deliver_crew_membership_accepted)
      UserMailer.stubs(:deliver_crew_membership_ignored)

      @up = Factory :user_profile
      @user = @up.owner
      @up2 = Factory :user_profile
      @user2 = @up2.owner
    end

    should "not be able to add members to the PERSON crew" do
      count1 = CrewMembership.count
      crew = @user.crews.first :conditions => {:crew_type => Crew::Type::PERSON}
      params =  {:joined_crew => crew, :invitee_email => @user2.email_address}
      assert_raise(Hobo::PermissionDeniedError) { CrewMembership::Lifecycle.invite(@crew_owner, params) }
      count2 = CrewMembership.count
      assert_equal count1, count2
    end

  end
   
  context "A crew owner" do

    setup do

      UserMailer.stubs(:deliver_invite_user)
      UserMailer.stubs(:deliver_crew_membership_invitation)
      UserMailer.stubs(:deliver_crew_membership_accepted)
      UserMailer.stubs(:deliver_crew_membership_ignored)

      @crew = Factory(:crew)
      @crew_owner = @crew.owner
    end

    should "not be able invite without a valid email address" do
      params =  {:joined_crew => @crew}
      crew_membership = CrewMembership::Lifecycle.invite(@crew_owner, params)
      assert_nil crew_membership.id
      assert_nil crew_membership.invitee
    end

    should "be able to invite with a valid email address" do
      params =  {:joined_crew => @crew, :invitee_email => 'someone@domain.com'}
      crew_membership = CrewMembership::Lifecycle.invite(@crew_owner, params)
      assert_not_nil crew_membership.id
      assert_not_nil crew_membership.invitee
    end
    
    should "not be able to invite with the same email address again on an owner" do
      owner = @crew.owner
      params =  {:joined_crew => @crew, :invitee_email => owner.email_address}
      count1 = CrewMembership.count
      CrewMembership::Lifecycle.invite(@crew_owner, params)
      count2 = CrewMembership.count
      assert_equal count1, count2
    end
    
  end
  context "A crew with a membership" do

    setup do

      UserMailer.stubs(:deliver_invite_user)
      UserMailer.stubs(:deliver_crew_membership_invitation)
      UserMailer.stubs(:deliver_crew_membership_accepted)
      UserMailer.stubs(:deliver_crew_membership_ignored)

      cm = Factory :crew_membership, :state => "accepted"
      cm = CrewMembership.find(cm.id) #FIXME [Sjoerd] I don't understand why cm.joined_crew is damaged before this
      @crew = cm.joined_crew
      @crew_owner = @crew.owner
    end
    
    should "not be able to invite with the same email address again on a member" do
      owner = @crew.crew_memberships.first.owner
      params =  {:joined_crew => @crew, :invitee_email => owner.email_address}
      count1 = CrewMembership.count
      CrewMembership::Lifecycle.invite(@crew_owner, params)
      count2 = CrewMembership.count
      assert_equal count1, count2
    end
    
  end
  
  context "Given a lifecyle - with initial state of invited" do

    setup do

      UserMailer.stubs(:deliver_invite_user)
      UserMailer.stubs(:deliver_crew_membership_invitation)
      UserMailer.stubs(:deliver_crew_membership_accepted)
      UserMailer.stubs(:deliver_crew_membership_ignored)

      @crew = Factory(:crew)
      @crew_owner = @crew.owner
      @email = 'name@domain.com'

      params = {:joined_crew => @crew, :invitee_email => @email}
      @crew_membership = CrewMembership::Lifecycle.invite(@crew_owner, params)
      @lifecycle = @crew_membership.lifecycle

      @valid_key = @lifecycle.key
      @invalid_key = '1234567890'
    end

    should "respond to #accept!, #ignore! and #retract! transitions" do
      [:accept!, :ignore!, :retract!].each do |transition|
        assert @lifecycle.respond_to? transition        
      end
    end

    should "have ownership, invitee and crew correctly set" do
      assert_equal @crew_owner, @crew_membership.owner
      assert_equal User.find_by_email_address(@email), @crew_membership.invitee
      assert_equal @crew, @crew_membership.joined_crew
    end

    should "have initial lifecycle state set to #invited" do
      assert_equal 'invited', @crew_membership.state
    end

    context "given a guest user" do
      
      setup do
        @guest = Guest.new
      end
      
      context "an #accept! transition" do
        
        context "with the correct key" do

          setup do
            @lifecycle.provided_key = @valid_key
          end

          should "set the lifecycle state to #accepted" do
            assert_equal 'invited', @crew_membership.state
            @lifecycle.accept! @guest
            assert_equal 'accepted', @crew_membership.state
          end
        
        end #with the correct key

        context "with the wrong key" do

          setup do
            @lifecycle.provided_key = @invalid_key
          end

          should "not set the lifecycle state to #accepted" do
            assert_equal 'invited', @crew_membership.state
            @lifecycle.accept! @guest
            assert_not_equal 'accepted', @crew_membership.state
            assert_equal 'invited', @crew_membership.state
          end
        
        end #with the wrong key

      end #an #accept! transition

      context "an #ignore! transition" do

        context "with the correct key" do

          setup do
            @lifecycle.provided_key = @valid_key
          end

          should "set the lifecycle state to #ignored" do
            assert_equal 'invited', @crew_membership.state
            @lifecycle.ignore! @guest
            assert_equal 'ignored', @crew_membership.state
          end

        end #with the correct key

        context "with the wrong key" do

          setup do
            @lifecycle.provided_key = @invalid_key
          end

          should "not set the lifecycle state to #ignored" do
            assert_equal 'invited', @crew_membership.state
            @lifecycle.ignore! @guest
            assert_not_equal 'ignored', @crew_membership.state
            assert_equal 'invited', @crew_membership.state
          end

        end #with the wrong key

      end #an #ignore! transition

    end #given a guest user

    context "given the invitee" do

      setup do
        @invitee = User.find_by_email_address(@email)
      end

      context "an #accept! transition" do

        should "set the lifecycle state to #accepted" do
          assert_equal 'invited', @crew_membership.state
          @lifecycle.accept! @invitee
          assert_equal 'accepted', @crew_membership.state
        end
      end

      context "an #ignore! transition" do

        should "set the lifecycle state to #ignored" do
          assert_equal 'invited', @crew_membership.state
          @lifecycle.ignore! @invitee
          assert_equal 'ignored', @crew_membership.state
        end
      end
      
      context "a #retract! transition" do

        should "not work (leave the state as 'invited')" do
          assert_equal 'invited', @crew_membership.state
          @lifecycle.retract! @invitee
          assert_equal 'invited', @crew_membership.state
        end

      end

    end #given the invitee
    
    context "given the crew owner" do
      
      context "a #retract! transition" do

        should "set the lifecycle state to #retracted" do
          assert_equal 'invited', @crew_membership.state
          @lifecycle.retract! @crew_owner
          assert_equal 'retracted', @crew_membership.state
        end

      end #a #retract! transition

    end #given the crew owner

  end #Given a lifecyle - with initial state of invited
end
