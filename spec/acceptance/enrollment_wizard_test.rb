require File.dirname(__FILE__) + '/acceptance_helper'

#See
#    https://github.com/cavalle/steak
#    https://github.com/jnicklas/capybara
#    https://github.com/thoughtbot/factory_girl

include ActionController::UrlWriter
default_url_options[:host] = 'test.local'

feature "Enrollment Wizard." do
  describe "With An Event" do
    background do @event=Factory(:event)
      @organization = @event.organization
      @organization_admin = Factory(:user_profile).owner
      @organization.organization_admins << @organization_admin
      @organization.save!
      @role  = Factory(:registration_role, :operation=>'Enrollment')
      @event.registration_roles << @role
      @event.save!

      @boat_class=Factory(:equipment_type).boat_class
      @boat_class.organization = @organization; @boat_class.save!

      @event.boat_classes << @boat_class
      @event.save!
    end
    describe "A User" do
      background do
	@user=Factory(:user_profile).owner
	@applicant=@user
	login_as @applicant
      end
      scenario "enrolls" do
	visit event_path(@event)
	visit "/enrollment_wizards/register?enrollment_wizard%5Bregistration_role_id%5D=#{@role.id}"
	page.should have_content 'Register'
	find('.submit-button').click #Register
	
	page.should have_content @applicant.last_name
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
      end
    end
  end
end