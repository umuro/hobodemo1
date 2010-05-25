require 'factory_girl'

unless Factory.factories[:event]

  require File.join(File.dirname(__FILE__), 'event_series_factory')

  Factory.define :event do |f|
    
    class << f
      def default_event_series
        @default_event_series ||= Factory(:event_series)
      end
    end
    
    f.event_series { f.default_event_series }
    f.sequence(:name) {|n| "Event #{n}" }
    f.sequence(:if_event_id) {|n| "#{n}"}
    f.start_time {(Time.now.utc-2.days).at_beginning_of_day}
    f.end_time {(Time.now.utc+7.days).end_of_day}
    f.event_type :Regatta
  end

end