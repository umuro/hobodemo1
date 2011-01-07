require File.dirname(__FILE__) + '/../test_helper'

class EventFolderTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:event_folder)}
    should belong_to :organization #PARENT
    should validate_presence_of :organization #PARENT
    should validate_uniqueness_of(:name).scoped_to(:organization_id)

    should validate_presence_of :name
    
    should have_many :events
  end
end
