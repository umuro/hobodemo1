module EventLocalTime
  def EventLocalTime.included(base)
    attach_event_tz(base, base.new)
  end

  def self.attach_event_tz(klass, instance)
    if klass == Event
      klass.send(:define_method, 'event_tz') {
        self.time_zone.try(:to_tz)
      }
    else
      klass.send(:define_method, 'event_tz') {
        self.event.try(:time_zone).try(:to_tz)
      }
    end
    klass.send(:before_create, '_adjust_time_with_zone_object')
    klass.attr_order.select { |attr_name|
        (klass.columns_hash[attr_name.to_s].type == :datetime or
         klass.columns_hash[attr_name.to_s].type == :timestamp) and
        not [:created_at, :updated_at, :key_timestamp].include? attr_name}.each do |attr_name|

      attr_name = attr_name.to_s
      if not klass.instance_methods.include?(attr_name)
        klass.attr_types[attr_name.to_sym] = ActiveSupport::TimeWithZone # make sure hobo use the correct tag for display
        #new_field_spec = klass.field_specs[attr_name]
        #new_field_spec.options[:null] = false
        #klass.field_specs[new_attr_name] = new_field_spec

        klass.send(:define_method, attr_name) {
          if self.read_attribute(attr_name).present?
            if self.event_tz.present?
              val = self.read_attribute(attr_name).in_time_zone(self.event_tz)
              return val
            else
              self.read_attribute(attr_name)
            end
          end
        }
      end
      if not klass.instance_methods.include?(attr_name+'=')
        klass.send(:define_method, attr_name+'=') { |dt|
          _set_attr_event_time_zone(attr_name, dt)
        }
      end
    end
  end

  def _adjust_time_with_zone_object
    return if self.event_tz.nil?
    return if not self.new_record?
    sec_offset = Time.now.in_time_zone(self.event_tz).utc_offset.second
    self.class.attr_order.select { |attr_name|
        (self.class.columns_hash[attr_name.to_s].type == :datetime or
         self.class.columns_hash[attr_name.to_s].type == :timestamp) and
        not [:created_at, :updated_at, :key_timestamp].include? attr_name}.each do |attr_name|
      old_attr_val = self.read_attribute(attr_name)
      if old_attr_val.present?
        attr_val = old_attr_val.utc - sec_offset
        self.write_attribute(attr_name, attr_val.utc)
      end
    end
  end

  def _set_attr_event_time_zone(attr_name, dt)
    return if dt.nil?
    if self.event_tz.nil? || self.new_record?
      self.write_attribute(attr_name, dt)
    else
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
      val = DateTime.strptime(new_d)
      self.write_attribute(attr_name, val.utc)
    end
  end
end
