require 'factory_girl'

unless Factory.factories[:event_series]

  require File.join(File.dirname(__FILE__), 'organization_factory')

  Factory.define :event_series do |f|
    class << f
      def default_organization
        @default_organization ||= Factory(:organization)
      end
    end
    
    f.sequence(:name) {|n| "EventSeries#{n}"}
    f.organization { f.default_organization }
  end

end
