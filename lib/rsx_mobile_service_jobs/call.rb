module RsxMobileServiceJobs

  class Call
    @queue = :call_queue
    
    def self.queue; @queue; end
    
    def self.logger; @logger ||= RAILS_DEFAULT_LOGGER; end
    
    def log_info *text
      self.class.logger.info "Call - INFO  #{DateTime.now} - #{text.to_s}"
    end
    
    def self.log_error *text
      logger.error "Call - ERROR #{DateTime.now} - #{text.to_s}"
    end
    
    # The entrypoint for Resque
    
    def self.perform id
      
      Redis.current.set("rsx_mobile_service_too_late:#{id}", 0)

      if 0 <= Redis.current.ttl("rsx_mobile_service_discharge:#{id}")
        Resque.enqueue RsxMobileServiceJobs::Call, id
        return
      end
      
      Redis.current.set("rsx_mobile_service_too_late:#{id}", 1)
      
      begin
        o = self.new id
        o.start if o.rms
      rescue Exception => e
        log_error e.message
        raise e
      end
      
    
    end
    
    attr_accessor :rms
    
    
    def initialize id
      log_info ".. INITIALIZATION .........................................."
      # Retrieve the RsxMobileService record
      @rms = RsxMobileService.first :conditions => {:event_id => id }
    end
    
    
    # Startup processing and sending to the remote URL
    def start
      send_to_remote
    end
    
    def send_to_remote
      log_info "- Prepare XML"
      doc = Nokogiri::XML::Builder.new do |xml|
      xml.initiation {
        xml.id_ @rms.event_id
        xml.key @rms.api_key
      }
      end
      
      log_info "- Encrypt XML"
      contents = $SECURITY[:rsx_mobile_service].encrypt doc.to_xml
      
      raw_send_to_remote contents
    end
    
    def raw_send_to_remote contents
      log_info "Sending data to remote server"
      url = URI.parse($RSX_MOBILE_SERVICE_REMOTE_URL)
      
      Net::HTTP.start(url.host, url.port) { |http|
        full = url.path
        full = "#{full}?#{url.query}" if url.query
        log_info "- J-Path: #{full}"
        response = http.request_post full, contents
        log_info "- J-Response: #{response.body}"
        response.value
      }
    end
  end
  
end
