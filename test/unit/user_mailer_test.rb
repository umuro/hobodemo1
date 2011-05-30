require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < Test::Unit::TestCase
  include ActionController::UrlWriter

#   SETUP_ARGS = [:host_with_port]

  def global_setup

#     SETUP_ARGS.each do |x|
#       raise ArgumentError, "Argument #{x} is nil" if args[x].nil?
#     end

    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @request = mock()
    @host_with_port = 'www.test.com:8080'
    @request.stubs(:host_with_port).returns(@host_with_port)

    @controller = mock()
    @controller.stubs(:request).returns(@request)
    @controller.stubs(:call_tag).returns(nil)

    @key = '1234567890'

    Thread.current['Hobo.current_controller'] = @controller
  end
  
  context "A user invitation email" do

    setup do

      global_setup

      @invitor = Factory(:user)
      @invitee = Factory(:user, :state => 'invited')

      @activation_url = user_accept_invitation_url :host => @host_with_port, 
                                                   :id => @invitee, 
                                                   :key => @key
    end

    should "be sent with the correct information" do

      UserMailer.deliver_invite_user(@invitor, @invitee.email_address, @key)

      mail = ActionMailer::Base.deliveries[0]

      assert_equal 1, ActionMailer::Base.deliveries.count
      assert_match /Become a member/, mail.subject
      assert_equal @invitee.email_address, mail.to[0]
      assert_match /invitation email to join the #{@host_with_port} platform/, mail.body
      assert_match /click the link below to activate your account/, mail.body
      assert_match @activation_url, mail.body
    end

  end

  context "A crew membership invitation email" do

    setup do

      global_setup

      @membership = Factory(:crew_membership)
      @crew = @membership.joined_crew
      @recipient = @membership.invitee.email_address

      @cm_accept_url = crew_membership_accept_url :host => @host_with_port, 
                                                  :id => @membership.id, :key => @key

      @cm_ignore_url = crew_membership_ignore_url :host => @host_with_port, 
                                                  :id => @membership.id, :key => @key
    end

    should "be sent with the correct information" do

      UserMailer.deliver_crew_membership_invitation(@membership, @key)

      mail = ActionMailer::Base.deliveries[0]

      assert_equal 1, ActionMailer::Base.deliveries.count
      assert_match /#{@crew.name} crew membership invitation/, mail.subject
      assert_equal @recipient, mail.to[0]
      assert_match /invitation email to join the #{@crew.name} crew/, mail.body
      assert_match /click the link below to accept the invitation/, mail.body
      assert_match @cm_accept_url, mail.body
      assert_match /do not wish to become a member/, mail.body
      assert_match @cm_ignore_url, mail.body
    end

  end
  
  context "A crew membership invitation acceptance email" do

    setup do

      global_setup

      @membership = Factory(:crew_membership)
      @crew = @membership.joined_crew
      @recipient = @membership.owner.email_address
      @invitee_email = @membership.invitee.email_address
    end

    should "be sent with the correct information" do

      UserMailer.deliver_crew_membership_accepted(@membership)

      mail = ActionMailer::Base.deliveries[0]

      assert_equal 1, ActionMailer::Base.deliveries.count
      assert_match /#{@crew.name} membership accepted/, mail.subject
      assert_equal @recipient, mail.to[0]
      assert_match /#{@invitee_email} has accepted your invitation/, mail.body
      assert_match /join the #{@crew} crew/, mail.body
    end

  end

  context "An ignored crew membership invitation email" do

    setup do

      global_setup

      @membership = Factory(:crew_membership)
      @crew = @membership.joined_crew
      @recipient = @membership.owner.email_address
      @invitee_email = @membership.invitee.email_address
    end

    should "be sent with the correct information" do

      UserMailer.deliver_crew_membership_ignored(@membership)

      mail = ActionMailer::Base.deliveries[0]

      assert_equal 1, ActionMailer::Base.deliveries.count
      assert_match /#{@crew.name} membership ignored/, mail.subject
      assert_equal @recipient, mail.to[0]
      assert_match /#{@invitee} has ignored your invitation/, mail.body
      assert_match /join the #{@crew} crew/, mail.body
    end

  end
  
  context "A user signup activation email" do
    
    setup do

      global_setup

      @user = Factory(:user)
      @activation_url = user_activate_signup_url :host => @host_with_port, 
                                                 :id => @user, 
                                                 :key => @key
    end

    should "be sent with the correct information" do

      UserMailer.deliver_signup_activation(@user.email_address, @key)

      mail = ActionMailer::Base.deliveries[0]

      assert_equal 1, ActionMailer::Base.deliveries.count
      assert_match /Activate your account/, mail.subject
      assert_equal @user.email_address, mail.to[0]
      assert_match /activation email/, mail.body
      assert_match /click the link below to start using your account/, mail.body
      assert_match @activation_url, mail.body
    end
    
  end

  context "Enrollment" do
    
    setup do
      global_setup
      @user = Factory(:user)
      @enrollment = Factory(:enrollment, :owner=>@user)
    end

    context "enrollment rejected email" do

      setup do
        UserMailer.deliver_event_abstract_registration_rejected(@enrollment)
      end

      should "be sent with the correct information" do
        mail = ActionMailer::Base.deliveries[0]

        assert_equal 1, ActionMailer::Base.deliveries.count
        assert_match /enrollment rejected/, mail.subject
        assert_equal @user.email_address, mail.to[0]
        assert_match /has been rejected/, mail.body      
      end
    end

    context "enrollment accepted email" do

      setup do
        UserMailer.deliver_event_abstract_registration_accepted(@enrollment)
      end

      should "be sent with the correct information" do
        mail = ActionMailer::Base.deliveries[0]

        assert_equal 1, ActionMailer::Base.deliveries.count
        assert_match /enrollment accepted/, mail.subject
        assert_equal @user.email_address, mail.to[0]
        assert_match /has been accepted/, mail.body      
      end
    end
    
  end
end