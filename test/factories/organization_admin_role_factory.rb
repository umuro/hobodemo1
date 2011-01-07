#test/factories/organization_admin_role_factory.rb
require 'factory_girl'

Factory.define :organization_admin_role do |f|

  require File.join(File.dirname(__FILE__), 'organization_factory')
  require File.join(File.dirname(__FILE__), 'user_factory')

  class << f

    def default_user
      @default_user = Mill.unless_produced?(:user, @default_user) #Factory(:user)
    end

    def default_organization
      @default_organization = Mill.unless_produced?(:organization, @default_organization)#Factory(:organization)
    end
  end

  f.organization { f.default_organization }
  f.user { f.default_user }
end