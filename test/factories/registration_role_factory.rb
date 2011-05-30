#test/factories/registration_role_factory.rb
require 'factory_girl'

unless Factory.factories[:registration_role]

  Factory.define :registration_role do |f|
    class << f
      def default_event
        @default_event = Mill.unless_produced?(:event, @default_event) #{Factory(:default_event)}
      end
    end
    f.event {f.default_event}
    f.sequence(:name) {|n| "Role #{n}"}
    f.operation { 'Default' }
    f.external_markdown {"Test markdown"}
  end

end