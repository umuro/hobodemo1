#test/factories/enrollment_factory.rb
require 'factory_girl'

unless Factory.factories[:enrollment]

  Factory.define :enrollment do |f|

    class << f
      def default_owner
        @default_owner = Mill.unless_produced?(:user, @default_owner) #{Factory(:user)}
      end
    end
    
    f.state "requested"
    f.country { Factory(:country) }
    f.owner { f.default_owner }
    f.event { Factory(:event) }
    f.boat {|r| Factory(:boat, :owner => r.owner) }
    f.crew {|r| Factory(:crew, :owner => r.owner) }

    #NOTE. r.owner means owner of the generated record.
    #This way if Factory :enrolment, :owner=>user is called everything is correctly set.
    #Setting those properties from the default prevents passing an argument
  end

end