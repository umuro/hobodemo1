module RsxMobileServiceJobs

  class Touched
    
    def extend seconds, id
      Redis.current.setex "rsx_mobile_service_discharge:#{id}", seconds, ""
    end
    
    def enqueue seconds, record
      return if record.shadow_mode
      if -1 == Redis.current.ttl("rsx_mobile_service_discharge:#{record.id}").to_i
        extend seconds, record.id
        Resque.enqueue RsxMobileServiceJobs::Call, record.id
      else
        extend seconds, record.id
        if 1 == Redis.current.get("rsx_mobile_service_too_late:#{record.id}").to_i
          Resque.enqueue RsxMobileServiceJobs::Call, record.id
        end
      end
    end
    
    def after_save record
      enqueue $RSX_MOBILE_SERVICE_REMOTE_TTL, record
    end
  end
end
