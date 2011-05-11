require File.dirname(__FILE__) + '/../test_helper'

class CalendarEntryTest < ActiveSupport::TestCase
  context "ActiveRecord" do
    setup do
      @entry = Factory(:calendar_entry)
    end

    context "fields" do
      should have_db_column(:name).of_type(:string)
      should have_db_column(:scheduled_time).of_type(:datetime)
    end

    context "validations" do
      should validate_presence_of :event    #PARENT
#      should_validate_uniqueness_of :name, :scoped_to=>:event_id    #PARENT
      should validate_uniqueness_of(:name).scoped_to(:event_id)
    end

    context "relations" do
      should belong_to :event    #PARENT
    end
  end
end
