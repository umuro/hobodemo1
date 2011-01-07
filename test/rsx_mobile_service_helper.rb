require 'resque'

module Resque
  def self.enqueue_with_stubbing klass, *args
    klass.perform *args
  end
end

#Redis.current.set("rsx_mobile_service_too_late:#{id}", 0)

class LowLevelStub
  def initialize
    @hash = {}
    @ttl = {}
  end
  
  def set key, value
    raise "Must be a string" unless value.is_a? ::String or value.is_a? ::Integer
    @ttl[key] = nil
    @hash[key] = value
  end
  
  def get key
    if intern_ttl(key) < -1 or ttl(key) >= 0
      @hash[key]
    else
      @hash[key] = nil
    end
  end
  
  def setex key, ttl, value
    set key, value
    @ttl[key] = ttl.seconds.from_now
  end
  
  def ttl key
    v = intern_ttl key
    if v >= 0; v else -1 end
  end
  
  private
  
  def intern_ttl key
    return -2 if @ttl[key] == nil
    v = @ttl[key] - DateTime.now
    if v >= 0
      v
    else
      -1
    end
  end
end

require 'redis'

class Redis
  def self.current_with_stubbing
    return @low_level_stub ||= LowLevelStub.new
  end
end

$RSX_MOBILE_SERVICE_REMOTE_TTL = 0.001

require 'rsx_mobile_service_jobs/call'
require 'rsx_mobile_service_jobs/position_update'
require 'rsx_mobile_service_jobs/touched'

module RsxMobileServiceJobs
  class Call
    class << self
      def perform_with_sleep *args
        sleep $RSX_MOBILE_SERVICE_REMOTE_TTL
        perform_without_sleep *args
      end
      alias_method_chain :perform, :sleep
    end
    
    def raw_send_to_remote contents
      $RSX_MOBILE_SERVICE_CALL_EXECUTED = true
    end
  end
end
