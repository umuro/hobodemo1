require File.dirname(__FILE__) + '/../test_helper'

class OrganizationAdminRoleTest < ActiveSupport::TestCase
  context "Active Record" do
    setup {Factory(:organization_admin_role)}
    should belong_to :organization #PARENT
    should validate_presence_of :organization #PARENT
    
    should belong_to :user
    should validate_presence_of :user
  end
end
