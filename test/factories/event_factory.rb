require 'factory_girl'

unless Factory.factories[:event]

  Factory.define :event do |f|

    class << f
      def default_event_folder
        @default_event_folder =  Mill.unless_produced?(:event_folder, @default_event_folder) #Factory(:event_folder)
      end
    end

    f.event_folder { f.default_event_folder }
    f.sequence(:name) {|n| "Event #{n}" }
    f.sequence(:if_event_id) {|n| "#{n}"}
    f.start_time {(Time.now.utc+2.days).at_beginning_of_day}
    f.end_time {(Time.now.utc+7.days).end_of_day}
#     f.event_type :Regatta
    f.time_zone {ActiveSupport::TimeZone.all.*.name.sample}
    f.place { |this| this.time_zone }
  end

end