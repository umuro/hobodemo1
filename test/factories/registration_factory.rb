#test/factories/registration_factory.rb
require 'factory_girl'

unless Factory.factories[:registration]

require File.join(File.dirname(__FILE__), 'registration_role_factory')

  Factory.define :registration do |f|

    class << f
      def default_owner
        @default_owner = Mill.unless_produced?(:user, @default_owner) #{Factory(:user)}
      end
      def default_registration_role
        default_registration_role = Mill.unless_produced?(:registration_role, @default_registration_role)
      end
    end

    f.owner { f.default_owner }
    f.registration_role { f.default_registration_role }
    f.state "requested"
  end

end