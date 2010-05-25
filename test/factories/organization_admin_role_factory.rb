#test/factories/user.rb
require 'factory_girl'
# require File.join(File.dirname(__FILE__), 'user_factory')
# require File.join(File.dirname(__FILE__), 'organization_factory')

Factory.define :organization_admin_role do |f|
  class << f
    def default_user
      @default_user ||= Factory(:user)
    end
    def default_organization
      @default_organization ||= Factory(:organization)
    end
  end
  
  f.organization_id { f.default_organization.id }
  f.user_id { f.default_user.id }
end

