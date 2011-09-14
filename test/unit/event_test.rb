require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:event)}
    should belong_to :event_folder   #PARENT
    should validate_presence_of :event_folder #PARENT
#     should_validate_uniqueness_of :name, :scoped_to=>:event_folder_id #PARENT
      should validate_uniqueness_of(:name).scoped_to(:event_folder_id)
    should validate_presence_of :name  
    
    should have_many :boat_classes
    should have_many :boats
    should have_many :races
    should have_many :course_areas    
    should have_many :enrollments
    should have_many :event_spotter_roles
    should have_many(:event_spotters).through(:event_spotter_roles)
  end
  
  context "A new event" do
    setup {@event=Factory.build(:event)}
    subject {@event}
    should "have default registration_only" do
      v = EVENT_CONFIG[:registration_only]
      assert_equal v, subject.registration_only
    end
  end
  
  context "A stored event" do
    setup {@event=Factory.create(:event)}
    subject {@event}
    should "have default registration_only stored" do
      v = EVENT_CONFIG[:registration_only]
      assert_equal v, subject[:registration_only]
    end
  end


  context "Event TimeZone for event-related classes" do
    @klasses = ActiveRecord::Base.send(:subclasses).select do |m|
        (m.instance_methods.include?('event') or m.name == 'Event') and
        (m.columns_hash.values.*.type.count(:datetime) > 2)
    end

    @klasses.each do |klass|
      context "Class #{klass}" do
        setup do
          @attrs = klass.attr_order.select{|attr_name| klass.columns_hash[attr_name.to_s].type == :datetime and not [:created_at, :updated_at, :key_timestamp].include? attr_name}
        end
	#key_timestamp is internally used by Hobo to manage transitions
	
        context "given an instance" do
          setup do
            @instance = Factory(:"#{klass.name.underscore}")
            @dt = DateTime.now
            @dt_e = @dt.in_time_zone(@instance.event_tz)
            @dt_e_s = @dt_e.strftime('%FT%T%z')
          end

          context "with its event's timezone set to nil" do
            setup do
              if klass == Event
                @instance.time_zone = nil
              else
                @instance.event.time_zone = nil
              end
            end
            should "time-zone related attributes return value in UTC" do
              @attrs.each do |attr|
                new_attr_name = attr.to_s+'_event'
                assert_equal @instance.send(attr),@instance.read_attribute(attr)
              end
            end
          end

          context "with its event's timezone set to non-nil value" do
            setup do
            end
            should "time-zone related attributes return value in the event's timezone" do
              @attrs.each do |attr|
                if @instance.send(attr) == nil  # factory doesn't set the attribute value, so we need to set it
                  @instance.send(attr.to_s+'=', @dt)
                end
                new_attr_name = attr.to_s+'_event'
                assert_equal @instance.send(attr), @instance.read_attribute(attr).in_time_zone(@instance.event_tz)
              end
            end
          end

        end
      end
    end
  end
end
