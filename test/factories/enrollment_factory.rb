#test/factories/enrollment_factory.rb
require 'factory_girl'

unless Factory.factories[:enrollment]

require File.join(File.dirname(__FILE__), 'registration_role_factory')

  Factory.define :enrollment do |f|

    class << f
      def default_owner
        @default_owner = Mill.unless_produced?(:user, @default_owner) #{Factory(:user)}
      end
      def default_registration_role
        @default_registration_role = Mill.unless_produced?(:registration_role, @default_registration_role) { Factory(:registration_role, :operation => RegistrationRole::OperationType::ENROLLMENT)}
      end
    end
    
    f.state "requested"
    f.country { Factory(:country) }
    f.owner { f.default_owner }
    f.registration_role { f.default_registration_role }
    f.boat {|r| Factory(:boat, :owner => r.owner) }
    f.crew {|r| Factory(:crew, :owner => r.owner) }

    #NOTE. r.owner means owner of the generated record.
    #This way if Factory :enrolment, :owner=>user is called everything is correctly set.
    #Setting those properties from the default prevents passing an argument
  end

end