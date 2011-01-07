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

class CrewMembershipsControllerTest < ActionController::TestCase

  context "Guest" do

    context "crew membership lifecycle actions" do

      setup do
        @cm = Factory(:crew_membership, :state => 'invited')
        @crew = @cm.joined_crew
      end

      should "not perform an #invite" do
        post :invite, :crew_membership => {:invitee_email => 'name@domain.com', 
                                           :joined_crew_id => @crew}
        assert_response :forbidden
      end

      should "not perform a #retract" do
        post :do_retract, :id => @cm.id
        assert_response :forbidden
      end

      should "not perform an #accept" do
        post :do_accept, :id => @cm.id
        assert_response :forbidden
        assert_equal 'invited', @cm.state
      end

      should "not perform an #ignore" do
        post :do_ignore, :id => @cm.id
        assert_response :forbidden
        assert_equal 'invited', @cm.state
      end

    end

  end

  context "A user" do

    context 'owning a crew' do

      setup do
        @invitor = Factory(:user)
        @crew = Factory(:crew, :owner => @invitor)
      end

      context "inviting an existing user to the crew" do

        setup do

          @invitee = Factory(:user)
          
          login_as @invitor
          post :do_invite, :crew_membership => {:invitee_email => @invitee.email_address, 
                                                :joined_crew_id => @crew.id}

          assert_response :found
        end
        
        should "create a crew membership" do

          @cm = CrewMembership.first
          assert_equal @invitee, @cm.invitee
          assert_equal @invitor, @cm.owner
          assert_equal @crew, @cm.joined_crew
          assert_equal 'invited', @cm.state
        end

      end

      context "inviting a new user by email" do

        setup do

          login_as @invitor
            @invitee_email = 'someone@domain.com'
            post :do_invite, :crew_membership => {:invitee_email => @invitee_email, 
                                                  :joined_crew_id => @crew.id}
            assert_response :found
          logout

          @invitee = User.find_by_email_address(@invitee_email)
        end

        should "create the new user" do
          assert_not_nil @invitee
        end

        should "create a crew membership" do
          @cm = CrewMembership.last
          assert_equal @invitee, @cm.invitee
          assert_equal @invitor, @cm.owner
          assert_equal @crew, @cm.joined_crew
          assert_equal 'invited', @cm.state
        end

      end

    end

    context 'invited to join a crew' do

      setup do
        
        @cm = Factory(:crew_membership, :state => 'invited')

        @owner = @cm.owner
        @invitee = @cm.invitee
        @crew = @cm.joined_crew
      end

      context 'when logged-in' do

        setup do

          assert_equal 'invited', @cm.state
          assert_equal @invitee, @cm.invitee
          assert_equal @owner, @cm.owner
          assert_equal @crew, @cm.joined_crew
          
          assert_not_equal @owner, @invitee
          assert_not_equal @cm.invitee, @cm.owner
        end

        should "be able to ignore the invitation" do

          login_as @invitee
            post :do_ignore, :id => @cm.id
            assert_response :found
          logout

          cm = CrewMembership.find(@cm.id)
          assert_equal 'ignored', cm.state 
        end
        
        should "be able to accept the invitation" do

          login_as @invitee  
            post :do_accept, :id => @cm.id
            assert_response :found
          logout

          cm = CrewMembership.find(@cm.id)
          assert_equal 'accepted', cm.state
        end

        should "not be able to retract the invitation" do

          login_as @invitee
            post :do_retract, :id => @cm.id
            assert_response :forbidden
          logout

          cm = CrewMembership.find(@cm.id)
          assert_equal 'invited', cm.state
        end

      end

    end

  end

end