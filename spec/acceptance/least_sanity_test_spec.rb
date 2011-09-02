require File.dirname(__FILE__) + '/acceptance_helper'

#See
#    https://github.com/cavalle/steak
#    https://github.com/jnicklas/capybara
#    https://github.com/thoughtbot/factory_girl

feature "Least Sanity Test", %q{
  User browsing the site
} do

  background {
    @event = Factory(:event)
    @boat_class = Factory(:boat_class, :organization=>@event.organization)
    @calendar_entry = Factory(:calendar_entry, :event=>@event)
    @race = Factory(:race, :boat_class=>@boat_class, :event=>@event)
    @fleet_race = Factory(:fleet_race, :race=>@race)
  }
  
  describe "Given an Event with the time zone being set" do
    describe "As a User coming to the site" do
      describe "I visit the front page" do
        background {visit "/"}
        scenario "I view" do
          page.should have_content(@event.name)
        end
        
        describe "I visit the event page" do
          background {find('.event-link').click}
          
          scenario "I view" do
            page.should have_content(@event.name)
            page.should have_content('Start Time Event')
          end
          
          scenario "I visit the race page" do
            find('.race-link').click
            page.should have_content(@race.number.to_s)
            page.should have_content(@boat_class.name)
            within('.collection.fleet-races') do
              page.should have_content(@fleet_race.color)
              page.should have_content('Scheduled Time Event')
            end
          end

          scenario "I visit calendar entries page" do
            find('.more.calendar_entries-link').click
            page.should have_content(@calendar_entry.name)
            page.should have_content(@fleet_race.color)
          end
        end
      end
    end # User viewing the site
  end # Event with time zone

  describe "Given an Event without the time zone being set" do
    background do
      @event.time_zone = nil
      @event.save
      @calendar_entry.scheduled_time = Time.now.utc.at_beginning_of_day # adjust scheduled time so that entry is visible
      @calendar_entry.save
      @fleet_race.scheduled_time = Time.now.utc.at_beginning_of_day # adjust scheduled time so that entry is visible
      @fleet_race.save
    end
    describe "As a User coming to the site" do
      describe "I visit the front page" do
        background {visit "/"}
        scenario "I view" do
          page.should have_content(@event.name)
        end
        
        describe "I visit the event page" do
          background {find('.event-link').click}
          
          scenario "I view" do
            page.should have_content(@event.name)
            page.should_not have_content('Start Time')
          end
          
          scenario "I visit the race page" do
            find('.race-link').click
            page.should have_content(@race.number.to_s)
            page.should have_content(@boat_class.name)
            within('.collection.fleet-races') do
              page.should have_content(@fleet_race.color)
              page.should_not have_content('Scheduled Time')
            end
          end

          scenario "I visit calendar entries page" do
            find('.more.calendar_entries-link').click
            page.should have_content(@calendar_entry.name)
            page.should have_content(@fleet_race.color)
          end
        end
      end
    end # User viewing the site
  end # Event without time zone

  describe "As a User without user profile coming to the site " do
    background do
      @user = Factory(:user)
      @user_name_label = @user.email_address.to_html
      @boat = Factory(:boat, :owner=>@user, :boat_class=>@boat_class)
      login_as @user
    end

    describe "I visit the front page" do
      background {visit "/"}
      scenario "I view" do
        page.should have_content("Create your user profile")
      end
#       
#       describe "I visit the account page" do
#         background {find('.user-link').click}
#         
#         scenario "I view" do
#           within('.view.user-label') do
#             page.should have_content(@user_name_label)
#           end
#           within('.collection.boats') do
#             page.should have_content(@boat.sail_number)
#             page.should have_content(@user_name_label)
#           end
#           within('.collection.crews') do
#             page.should have_content(@user_name_label)
#           end
#         end
#         
#         scenario "I visit the boat page" do
#           find('.boat-link').click
#           page.should have_content(@boat_class.name)
#         end
#       end

    end
  end # User without user profile

  describe "As a User with a user profile coming to the site " do
    background do
      @user = Factory(:user_profile).owner
      @user_profile = @user.user_profile
      @user_name_label = "#{@user_profile.last_name}, #{@user_profile.first_name} #{@user_profile.middle_name}"
      @boat = Factory(:boat, :owner=>@user, :boat_class=>@boat_class)
      login_as @user
    end

    describe "I visit the front page" do
      background {visit "/"}
      scenario "I view" do
        page.should have_content(@event.name)
      end
      
      describe "I visit the account page" do
        background {find('.user-link').click}
        
        scenario "I view" do
          within('.view.user-label') do
            page.should have_content(@user_name_label)
          end
          within('.collection.boats') do
            page.should have_content(@boat.sail_number)
            page.should have_content(@user_name_label)
          end
          within('.collection.crews') do
            page.should have_content(@user_name_label)
          end
        end

        scenario "I visit the boat page" do
          find('.boat-link').click
          page.should have_content(@boat_class.name)
        end
      end
    end
  end # User with a user profile
end
