module EventLocalTime
  def EventLocalTime.included(base)
    attach_event_tz(base, base.new)
  end

  def self.attach_event_tz(klass, instance)
    if klass == Event
      klass.send(:define_method, 'event_tz') {
        self.time_zone.nil? ? nil : self.time_zone.to_tz
      }
    else
      klass.send(:define_method, 'event_tz') {
        self.event.time_zone.nil? ? nil : self.event.time_zone.to_tz
      }
    end
    klass.attr_order.select { |attr_name|
        (klass.columns_hash[attr_name.to_s].type == :datetime or
         klass.columns_hash[attr_name.to_s].type == :timestamp) and
        not [:created_at, :updated_at].include? attr_name}.each do |attr_name|

      attr_name = attr_name.to_s
      new_attr_name = attr_name+'_event'
      if not klass.instance_methods.include?(new_attr_name)
        klass.attr_types[new_attr_name.to_sym] = ActiveSupport::TimeWithZone
        new_field_spec = klass.field_specs[attr_name]
        #new_field_spec.options[:null] = false
        klass.field_specs[new_attr_name] = new_field_spec

        klass.send(:define_method, new_attr_name) {
          if self.event_tz != nil and self.send(attr_name) != nil
            self.send(attr_name).in_time_zone(self.event_tz)
          end
        }
      end
      if not klass.instance_methods.include?(new_attr_name+'=')
        klass.send(:define_method, new_attr_name+'=') { |dt|
          _set_attr_event_time_zone(attr_name, dt)
        }
      end
    end
  end

  def _set_attr_event_time_zone(attr_name, dt)
    return if self.event_tz.nil?
    return if dt.nil?
    new_attr_name = attr_name+'_event'
    event_tz = DateTime.now.in_time_zone(self.event_tz).to_datetime.zone
    if dt.class.ancestors.include? Hash
      new_d = ''+dt['year']+'-'+dt['month']+'-'+dt['day']+'T'+dt['hour']+':'+dt['minute']+':00'+event_tz
    elsif dt.respond_to? :strftime
      new_d = "#{dt.strftime '%FT%T'}#{event_tz}"
    elsif dt.instance_of? String
      return if dt.length==0
      dt[10] = 'T'
      new_d = dt+event_tz
    end
    self.send(attr_name+'=',DateTime.strptime(new_d))
  end
end
