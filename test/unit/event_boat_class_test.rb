require File.dirname(__FILE__) + '/../test_helper'

class EventBoatClassTest < ActiveSupport::TestCase
  context "Active Record" do
    setup do
    end

    context "validations" do
      should validate_presence_of :event
      should validate_presence_of :boat_class
    end

    context "relations" do
      should belong_to :event
      should belong_to :boat_class
    end

  end
end
