require File.dirname(__FILE__) + '/../test_helper'

class Organization
  register_update_trigger :my_trigger
  
  def my_trigger scenario
    touch if scenario == :event
  end
end

class EventFolder
  register_update_trigger :my_trigger
  
  def my_trigger scenario
    touch if scenario == :event
  end
  
  delegate_update_trigger :scenario => :event, :recipient => :organization
end

class Event
  initiate_update_trigger :recipient => :event_folder, :on => :start_time
end

class TriggerUpdateTest < ActiveSupport::TestCase
  context "A defined trigger update" do
    setup do
      event_folder = Factory :event_folder
      organization = Factory :organization
      event_folder.organization = organization
      event_folder.save!
      @event = Event.create(:event_folder => event_folder,
                            :name => "Test Event for Trigger Update",
                            
                            :start_time => DateTime.now,
                            :end_time => DateTime.now + 1.hours)
      @event.save!
    end
    
    should "perform properly" do
      update1a = @event.event_folder.updated_at
      update1b = @event.event_folder.organization.updated_at
      @event.start_time = @event.start_time + 1.hours
      Delorean.time_travel_to 1.day.from_now do
        @event.save!
      end
      update2a = Event.find(@event.id).event_folder.updated_at
      update2b = Event.find(@event.id).event_folder.organization.updated_at
      assert_not_equal update1a.to_i, update2a.to_i
      assert_not_equal update1b.to_i, update2b.to_i
    end
    
    should "not do anything" do
      update1a = @event.event_folder.updated_at
      update1b = @event.event_folder.organization.updated_at
      @event.end_time = @event.end_time + 1.hours
      Delorean.time_travel_to 1.day.from_now do
        @event.save!
      end
      update2a = Event.find(@event.id).event_folder.updated_at
      update2b = Event.find(@event.id).event_folder.organization.updated_at
      assert_equal update1a.to_i, update2a.to_i
      assert_equal update1b.to_i, update2b.to_i
    end
  end
end
