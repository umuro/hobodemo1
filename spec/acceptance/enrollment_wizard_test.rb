require File.dirname(__FILE__) + '/acceptance_helper'

#See
#    https://github.com/cavalle/steak
#    https://github.com/jnicklas/capybara
#    https://github.com/thoughtbot/factory_girl

include ActionController::UrlWriter
default_url_options[:host] = 'test.local'

def scenario_enroll
      scenario "enrolls" do
	visit event_path(@event)
	url="/enrollment_wizards/register?enrollment_wizard[registration_role_id]=#{@role.id}"

	url = url+"&enrollment_wizard[applicant_id]=#{@applicant.id}" if whoami != @applicant
	
	visit url
	page.should have_content 'Register'
	find('.submit-button').click #Register
	
	page.body[@applicant.last_name].should be_true #How to match input value? It's not content'
	fill_in 'user_profile[last_name]', :with=>'Test'
	find('.submit-button').click #Save profile
	@applicant.last_name.should eql 'Test'

	page.should have_content 'Select Boat'
	page.should have_content 'Create Boat'
	boat_junction = current_url

	#A Create a boat
	find('.create-boat').click

	ba = Factory.attributes_for(:boat)
	fill_in 'boat[sail_number]', :with=>ba[:sail_number]
	select @boat_class.name, :from=>'boat[boat_class_id]'
	find('.submit-button').click #Create Boat

	page.should have_content 'Edit Equipment'

	#B Select a boat now
	visit boat_junction
	select @applicant.boats.first.sail_number, :from=>'enrollment_wizard[boat_id]'
	find('.submit-button').click #Select Boat

	page.should have_content 'Edit Equipment'
	find('.submit-button').click #Edit Equipment
	page.should have_content 'Select Crew'

	select @applicant.crews.first.label, :from=>'enrollment_wizard[crew_id]'
	find('.submit-button').click #Select Crew

	page.should have_content 'Select Country'
	select @applicant.country.name, :from=>'enrollment_wizard[country_id]'
	find('.submit-button').click #Select Country

	find('.submit-button').click #Apply
      end
end

feature "Enrollment Wizard." do
  describe "With An Event" do
    background do @event=Factory(:event)
      @organization = @event.organization
      @organization_admin = Factory(:user_profile).owner
      @organization.organization_admins << @organization_admin
      @organization.save!
      @role  = Factory(:registration_role_enrollment)
      @event.registration_roles << @role
      @event.save!

      @boat_class=Factory(:equipment_type).boat_class
      @boat_class.organization = @organization; @boat_class.save!

      @event.boat_classes << @boat_class
      @event.save!
    end
    describe "An applicant" do
      background do
	@applicant=Factory(:user_profile).owner
      end
      describe "himself" do
	background {login_as @applicant}
	scenario_enroll
      end
      describe "via organization admin" do
	background {login_as @organization_admin}
	scenario_enroll
	scenario "walk-in" do
	  url="/enrollment_wizards/walk_in?enrollment_wizard[registration_role_id]=#{@role.id}"
	  visit url
	  fill_in 'enrollment_wizard[email_address]', :with=>@applicant.email_address
	  find('.submit-button').click #Walk In
	  page.should have_content 'Register'
	  page.body[@applicant.email_address].should be_true
	end
      end
    end

    describe "organization admin" do
      background {login_as @organization_admin}
      scenario "walk-in new user" do
	url="/enrollment_wizards/walk_in?enrollment_wizard[registration_role_id]=#{@role.id}"
	visit url

	email_address = 'new@test.local'
	fill_in 'enrollment_wizard[email_address]', :with=>email_address
	find('.submit-button').click #Walk In
	page.should have_content 'Register'
	page.body[email_address].should be_true
      end
    end

  end
end