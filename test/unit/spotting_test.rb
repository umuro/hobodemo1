require File.dirname(__FILE__) + '/../test_helper'

class SpottingTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:spotting)}
    should belong_to :spotter 
    should validate_presence_of :spotter 
    should belong_to :spot 
    should validate_presence_of :spot 
    should belong_to :boat 
    should validate_presence_of :boat 
  end
end
