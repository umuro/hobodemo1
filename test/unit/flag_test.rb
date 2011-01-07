require File.dirname(__FILE__) + '/../test_helper'

class FlagTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:flag)}
    #should_validate_uniqueness_of :name
      should validate_uniqueness_of(:name)#.scoped_to(:organization_id)
    should validate_presence_of :name   
    
    should have_many :flaggings
  end
end
