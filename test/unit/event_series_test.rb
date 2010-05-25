require File.dirname(__FILE__) + '/../test_helper'

class EventSeriesTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:event_series)}
    should validate_uniqueness_of :name
    should validate_presence_of :name
    should belong_to :organization
    should have_many :events
  end
end
