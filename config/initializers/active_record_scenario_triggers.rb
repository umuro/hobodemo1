module ActiveRecord
  class Base
  
    # Triggers updates on parent, sibling or child objects whenever this record is updated
    def self.initiate_update_trigger var
      
      conditions = {}
      
      conditions[:if] = "#{var[:on]}_changed?".to_sym if var[:on]
      
      unless var[:scenario]
        var[:scenario] = self.model_name.underscore.to_sym
      end
      
      after_save conditions do |record|
        rcpt = record.send var[:recipient]
        if rcpt.is_a? ::Enumerable
          for v in rcpt
            v.class._update_triggered var[:scenario], v
          end
        else
          rcpt.class._update_triggered var[:scenario], rcpt
        end
        true
      end
    end
    
    def self._update_triggered scenario, o # :nodoc:
      return unless @_update_triggers
      @_update_triggers.each {|ut|
        if ut.is_a? ::Symbol
          o.send ut, scenario
        else
          ut.call o, scenario
        end
      }
    end
    
    # Defines symbols whose method equivalents are called on update with a scenario argument
    def self.register_update_trigger mthd
      @_update_triggers = [] unless @_update_triggers
      @_update_triggers << mthd
    end
    
    # Delegates update triggers based on a particular scenario, passing it to another parent/child/sibling
    def self.delegate_update_trigger var
      self.register_update_trigger(lambda {|o, scenario|
        if scenario == var[:scenario]
          rcpt = o.send var[:recipient]
          if rcpt.is_a? ::Enumerable
            for v in rcpt
              v.class._update_triggered var[:scenario], v
            end
          else
            rcpt.class._update_triggered var[:scenario], rcpt
          end
        end
      })
    end
  
  end
end
