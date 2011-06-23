#test/factories/organization_admin_role_factory.rb
require 'factory_girl'

Factory.define :event_spotter_role do |f|

  require File.join(File.dirname(__FILE__), 'event_factory')
  require File.join(File.dirname(__FILE__), 'user_factory')

  class << f

    def default_user
      @default_user = Mill.unless_produced?(:user, @default_user) #Factory(:user)
    end

    def default_event
      @default_event = Mill.unless_produced?(:event, @default_event) #Factory(:event)
    end
  end

  f.event { f.default_event }
  f.user { f.default_user }
end