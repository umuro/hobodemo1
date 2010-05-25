require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:event)}
    should validate_uniqueness_of :name
    should validate_presence_of :name
#     should have_method :organization
    should belong_to :event_series    
    should have_many :boats
    should have_many :races
    should have_many :course_areas    
    should have_many :team_participations
  end
end
