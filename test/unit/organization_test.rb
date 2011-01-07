require File.dirname(__FILE__) + '/../test_helper'

class OrganizationTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:organization)}
    should validate_uniqueness_of :name
    should validate_presence_of :name
    should have_many :event_folders
  end
end
