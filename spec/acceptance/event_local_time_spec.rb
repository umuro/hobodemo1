require File.dirname(__FILE__) + '/acceptance_helper'

#See 
#    https://github.com/cavalle/steak
#    https://github.com/jnicklas/capybara
#    https://github.com/thoughtbot/factory_girl

feature "Event's local time CRUD", %q{
  As an Organization Admin
  I want to CRUD event and related objects
} do

background {@attrs = Factory.attributes_for(:event)}

  describe "When organization admin, " do
    background do
      self.use_transactional_fixtures
      org_admin = Factory(:user)
      Factory(:organization_admin_role, :organization=>@attrs[:event_folder].organization, :user=>org_admin)
      login_as(org_admin)
    end

    describe "With nothing, " do
      describe "At list, " do
        background {visit "/event_folders/#{@attrs[:event_folder].id}"}
        scenario "I browse" do
          page.should_not have_content(@attrs[:name])
        end
        scenario "I create",:js=>true do
          find('.new-link.new-event-link').click
          page.should_not have_content('Start Time Event')
          page.should_not have_content('End Time Event')
          fill_in 'event[name]', :with=>@attrs[:name]
          fill_in 'event_start_time_date', :with=>@attrs[:start_time].strftime('%d/%m/%Y')
          find('#event_start_time_hour').select '08'
          find('#event_start_time_min').select '30'
          fill_in 'event_end_time_date', :with=>@attrs[:end_time].strftime('%d/%m/%Y')
          find('#event_end_time_hour').select '08'
          find('#event_end_time_min').select '30'
          click_button 'Create Event'

          visit "/event_folders/#{@attrs[:event_folder].id}"
          within('.collection.events .card.event') do
            page.should have_content @attrs[:name]
          end
        end
      end
    end

    describe "With event without timezone" do
      background do
        @event = Factory(:event, :time_zone=>nil, :event_folder=>@attrs[:event_folder])
        @course = Factory(:course, :organization=>@event.organization)
        @tz_name = ActiveSupport::TimeZone.all.*.name.sample
        @race = Factory(:race, :event=>@event)
      end
      describe "At show, " do
        background do
          @ce_attrs = Factory.attributes_for(:calendar_entry)
          @fr_attrs = Factory.attributes_for(:fleet_race, :race=>@race, :event=>@event, :scheduled_time=>(Time.now.utc.at_beginning_of_day-1.day))
          visit "/events/#{@event.id}"
        end
        scenario "I view" do
          page.should have_content('Start Time')
          page.should_not have_content('Start Time Event')
          page.should have_content @event.start_time.strftime('%d/%m/%Y %H:%M UTC')
          page.should have_content('End Time')
          page.should_not have_content('End Time Event')
          page.should have_content @event.end_time.strftime('%d/%m/%Y %H:%M UTC')
        end

        scenario "I edit and set the timezone" do
          find('.edit-link.event-link').click
          page.should_not have_content('Start Time Event')
          page.should_not have_content('End Time Event')
          find('#event_time_zone').select @tz_name
          #fill_in 'event_time_zone', :with=>@tz_name
          click_button 'Save'

          visit "/events/#{@event.id}"
          @event.reload # reload the object, since due to the edit before, the end time has been changed (form has 5 minute resolution)
          page.should have_content('Start Time Event')
          page.should have_content @event.start_time.in_time_zone(@tz_name).strftime('%d/%m/%Y %H:%M %z')
          page.should have_content('End Time Event')
          page.should have_content @event.end_time.in_time_zone(@tz_name).strftime('%d/%m/%Y %H:%M %z')
        end

        scenario "I create a new Calendar Entry",:js=>true do
          find('.new-link.new-calendar_entry-link').click
          page.should have_content('Scheduled Time')
          page.should_not have_content('Scheduled Time Event')
          fill_in 'calendar_entry[name]', :with=>@ce_attrs[:name]
          fill_in 'calendar_entry_scheduled_time_date', :with=>@ce_attrs[:scheduled_time].strftime('%d/%m/%Y')
          find('#calendar_entry_scheduled_time_hour').select '11'
          find('#calendar_entry_scheduled_time_min').select '45'
          click_button 'Create Calendar Entry'
          visit "/events/#{@event.id}"
          within('.collection.calendar-entries .card.calendar-entry') do
            page.should have_content @ce_attrs[:name]
          end

          find('.calendar-entry-link').click
          page.should have_content('Scheduled Time')
          page.should_not have_content('Scheduled Time Event')
          page.should have_content(@ce_attrs[:scheduled_time].strftime('%d/%m/%Y 11:45 ')+@ce_attrs[:scheduled_time].zone)
        end

        scenario "I create a new Fleet Race",:js=>true do
          find('.race-link').click

          find('.new-link.new-fleet_race-link').click
          fill_in 'fleet_race[color]', :with=>@fr_attrs[:color]
          fill_in 'fleet_race_scheduled_time_date', :with=>@fr_attrs[:scheduled_time].strftime('%d/%m/%Y')
          find('#fleet_race_scheduled_time_hour').select '11'
          find('#fleet_race_scheduled_time_min').select '45'
          find('.fleet-race-course-area').select @fr_attrs[:course_area].id.to_s
          click_button 'Create Fleet Race'

          visit "/races/#{@race.id}"
          page.should have_content @fr_attrs[:color]
          find('.fleet-race-link').click
          page.should have_content('Scheduled Time')
          page.should_not have_content('Scheduled Time Event')
          page.should have_content(@fr_attrs[:scheduled_time].strftime('%d/%m/%Y 11:45 ')+@fr_attrs[:scheduled_time].zone)
        end
      end
      describe "having a Calendar Entry" do
        background do
          @calendar_entry = Factory(:calendar_entry, :event=>@event)
        end
        scenario "I view the Calendar Entry and edit it", :js=>true do
          visit "/calendar_entries/#{@calendar_entry.id}"
          page.should have_content('Scheduled Time')
          page.should_not have_content('Scheduled Time Event')
          page.should have_content @calendar_entry.scheduled_time.strftime('%d/%m/%Y %H:%M UTC')

          find('.edit-link.calendar-entry-link').click
          page.should_not have_content 'Scheduled Time Event'
          new_scheduled_time = @calendar_entry.scheduled_time+1.day+15.minute
          fill_in 'calendar_entry_scheduled_time_date', :with=>new_scheduled_time.strftime('%d/%m/%Y')
          find('#calendar_entry_scheduled_time_hour').select new_scheduled_time.strftime('%H')
          find('#calendar_entry_scheduled_time_min').select new_scheduled_time.strftime('%M')
          click_button 'Save'

          @calendar_entry_x = CalendarEntry.find(@calendar_entry.id)
          assert_equal @calendar_entry_x.scheduled_time, new_scheduled_time

          visit "/calendar_entries/#{@calendar_entry.id}"
          page.should have_content('Scheduled Time')
          page.should_not have_content('Scheduled Time Event')
          page.should have_content new_scheduled_time.strftime('%d/%m/%Y %H:%M UTC')
        end
      end

      describe "having a Fleet Race" do
        background do
          @fleet_race = Factory(:fleet_race, :race=>@race, :scheduled_time=>Time.now.utc.at_beginning_of_day-1.day)
        end
        scenario "I view the Fleet Race and edit it",:js=>true do
          visit "/fleet_races/#{@fleet_race.id}"
          page.should have_content('Scheduled Time')
          page.should_not have_content('Scheduled Time Event')
          page.should have_content @fleet_race.scheduled_time.strftime('%d/%m/%Y %H:%M UTC')

          find('.edit-link.fleet-race-link').click
          page.should have_content 'Scheduled Time'
          new_scheduled_time = @fleet_race.scheduled_time+1.hour+15.minute
          fill_in 'fleet_race_scheduled_time_date', :with=>new_scheduled_time.strftime('%d/%m/%Y')
          find('.fleet-race-course').select @course.to_s
          find('#fleet_race_scheduled_time_hour').select new_scheduled_time.strftime('%H')
          find('#fleet_race_scheduled_time_min').select new_scheduled_time.strftime('%M')
          click_button 'Save'

          @fleet_race_x = FleetRace.find(@fleet_race.id)
          assert_equal @fleet_race_x.scheduled_time, new_scheduled_time

          visit "/fleet_races/#{@fleet_race.id}"
          page.should have_content 'Scheduled Time'
          page.should have_content new_scheduled_time.strftime('%d/%m/%Y %H:%M UTC')
        end
      end
    end

    describe "With event with timezone defined" do
      background do
        @event = Factory(:event, :event_folder=>@attrs[:event_folder])
        @race = Factory(:race, :event=>@event)
        @course = Factory(:course, :organization=>@event.organization)
      end
      describe "At show, " do
        background do
          @ce_attrs = Factory.attributes_for(:calendar_entry, :scheduled_time=>Time.now.utc.at_beginning_of_day)
          @fr_attrs = Factory.attributes_for(:fleet_race, :race=>@race, :event=>@event, :scheduled_time=>Time.now.utc.at_beginning_of_day-1.day)
          @dt = Time.now.utc.at_beginning_of_day+11.hour+45.minute
          visit "/events/#{@event.id}"
        end
        scenario "I view" do
          page.should have_content('Start Time Event')
          page.should have_content @event.start_time.in_time_zone(@event.time_zone.to_tz).strftime('%d/%m/%Y %H:%M %z')
          page.should have_content('End Time Event')
          page.should have_content @event.end_time.in_time_zone(@event.time_zone.to_tz).strftime('%d/%m/%Y %H:%M %z')
        end

        scenario "I create a new Calendar Entry",:js=>true do
          find('.new-link.new-calendar_entry-link').click
          page.should have_content('Scheduled Time Event')
          fill_in 'calendar_entry[name]', :with=>@ce_attrs[:name]
          fill_in 'calendar_entry_scheduled_time_event_date', :with=>@ce_attrs[:scheduled_time].strftime('%d/%m/%Y')
          find('#calendar_entry_scheduled_time_event_hour').select '11'
          find('#calendar_entry_scheduled_time_event_min').select '45'
          click_button 'Create Calendar Entry'
          visit "/events/#{@event.id}"
          within('.collection.calendar-entries .card.calendar-entry') do
            page.should have_content @ce_attrs[:name]
          end

          find('.calendar-entry-link').click
          page.should have_content('Scheduled Time Event')
          page.should have_content(@ce_attrs[:scheduled_time].strftime('%d/%m/%Y 11:45 ')+@event.start_time_event.strftime('%z'))
        end

        scenario "I create a new Fleet Race",:js=>true do
          find('.race-link').click

          find('.new-link.new-fleet_race-link').click
          fill_in 'fleet_race[color]', :with=>@fr_attrs[:color]
          fill_in 'fleet_race_scheduled_time_event_date', :with=>@fr_attrs[:scheduled_time].strftime('%d/%m/%Y')
          find('#fleet_race_scheduled_time_event_hour').select '11'
          find('#fleet_race_scheduled_time_event_min').select '45'
          find('.fleet-race-course-area').select @fr_attrs[:course_area].id.to_s
          click_button 'Create Fleet Race'

          visit "/races/#{@race.id}"
          page.should have_content @fr_attrs[:color]
          find('.fleet-race-link').click
          page.should have_content('Scheduled Time Event')
          page.should have_content(@fr_attrs[:scheduled_time].strftime('%d/%m/%Y 11:45 ')+@event.start_time_event.strftime('%z'))
        end
      end
      describe "having a Calendar Entry" do
        background do
          @calendar_entry = Factory(:calendar_entry, :event=>@event)
        end
        scenario "I view the Calendar Entry and edit it", :js=>true do
          visit "/calendar_entries/#{@calendar_entry.id}"

          page.should have_content @calendar_entry.name
          page.should have_content 'Scheduled Time Event'
          page.should have_content @calendar_entry.scheduled_time.in_time_zone(@event.time_zone.to_tz).strftime('%d/%m/%Y %H:%M %z')

          find('.edit-link.calendar-entry-link').click
          page.should have_content 'Scheduled Time Event'
          new_scheduled_time = @calendar_entry.scheduled_time+1.day+15.minute
          fill_in 'calendar_entry_scheduled_time_event_date', :with=>new_scheduled_time.strftime('%d/%m/%Y')
          find('#calendar_entry_scheduled_time_event_hour').select new_scheduled_time.strftime('%H')
          find('#calendar_entry_scheduled_time_event_min').select new_scheduled_time.strftime('%M')
          click_button 'Save'

          @calendar_entry_x = CalendarEntry.find(@calendar_entry.id)
          new_scheduled_time -= @calendar_entry.scheduled_time_event.utc_offset.second
          assert_equal @calendar_entry_x.scheduled_time, new_scheduled_time

          visit "/calendar_entries/#{@calendar_entry.id}"
          page.should have_content 'Scheduled Time Event'
          page.should have_content new_scheduled_time.in_time_zone(@event.time_zone).strftime('%d/%m/%Y %H:%M %z')
        end
      end

      describe "having a Fleet Race" do
        background do
          @fleet_race = Factory(:fleet_race, :race=>@race, :scheduled_time=>Time.now.utc.at_beginning_of_day-1.day)
        end
        scenario "I view the Fleet Race and edit it",:js=>true do
          visit "/fleet_races/#{@fleet_race.id}"

          page.should have_content @fleet_race.color
          page.should have_content 'Scheduled Time Event'
          page.should have_content @fleet_race.scheduled_time.in_time_zone(@event.time_zone).strftime('%d/%m/%Y %H:%M %z')

          find('.edit-link.fleet-race-link').click
          page.should have_content 'Scheduled Time Event'
          new_scheduled_time = @fleet_race.scheduled_time+15.minute
          fill_in 'fleet_race_scheduled_time_event_date', :with=>new_scheduled_time.strftime('%d/%m/%Y')
          find('.fleet-race-course').select @course.to_s
          find('#fleet_race_scheduled_time_event_hour').select new_scheduled_time.strftime('%H')
          find('#fleet_race_scheduled_time_event_min').select new_scheduled_time.strftime('%M')
          click_button 'Save'

          @fleet_race_x = FleetRace.find(@fleet_race.id)
          new_scheduled_time -= @fleet_race.scheduled_time_event.utc_offset.second
          assert_equal @fleet_race_x.scheduled_time, new_scheduled_time

          visit "/fleet_races/#{@fleet_race.id}"
          page.should have_content 'Scheduled Time Event'
          page.should have_content new_scheduled_time.in_time_zone(@event.time_zone).strftime('%d/%m/%Y %H:%M %z')
        end
      end

    end
  end
end
