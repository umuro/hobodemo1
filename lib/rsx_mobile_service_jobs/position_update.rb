module RsxMobileServiceJobs

  class PositionUpdate
    @queue = :position_update_queue
    
    def self.queue; @queue; end

    def logger; @logger ||= RAILS_DEFAULT_LOGGER; end
    
    def initialize rsx_mobile_service_id, xml
      log_info
      log_info ".. INITIALIZATION .........................................."
      @rsx_mobile_service_id = rsx_mobile_service_id
      @xml = xml
    end
    
    def log_info *text
      logger.info "PositionUpdate - INFO  #{DateTime.now} - #{text.to_s}"
    end
    
    
    def log_error *text
      logger.error "PositionUpdate - ERROR #{DateTime.now} - #{text.to_s}"
    end
    
    def open_schema
      schema_file = File.join RAILS_ROOT, 'public', 'schema', 'position-update.rnc'
      schema = nil
      File.open schema_file do |f|
        schema = Nokogiri::XML::RelaxNG f
      end
      schema
    end
    
    def open_xml
      doc = Nokogiri::XML @xml
      has_errors = false
      open_schema.validate(doc).each do |error|
        log_error error
        has_errors = true
      end
      return nil if has_errors
      log_info "Document validated"
      return doc
    end
    
    def perform_update position, event
      log_info "============================================================"
      log_info "Performing update for:"
      boat_id = position.xpath('@boat-id').to_s.to_i
      log_info "-- Boat identifier: #{boat_id}"
      fleet_race_id = position.xpath('@fleet-race-id').to_s.to_i
      log_info "-- Fleet race identifier: #{fleet_race_id}"
      time = DateTime.parse position.xpath('@time').to_s
      log_info "-- Time recording: #{time}"
      buoy = position.xpath('buoy/text()').to_s.to_i
      log_info "-- Buoy number: #{buoy}"
      log_info "------------------------------------------------------------"
      boat = Boat.find boat_id
      fleet_race = FleetRace.find fleet_race_id
      
      log_error "Event does not match fleet race" and return unless fleet_race.race.event == event
      
      log_info "Course   : #{fleet_race.course}"
      
      # Consider flags on spottings and convert them to the proper spot types
      position.xpath('flag').each do |flag|
        flagname = flag.xpath('text()').to_s.strip
        if flagname.eql? "start"
          log_info "Starting the race of boat #{boat_id}"
          unless fleet_race.start_time
            fleet_race.start_time = time 
            fleet_race.save!
          end
          spot = fleet_race.course.spots.first :conditions => {:spot_type => Spot::SpotType::OCS} #FIXME OCS = start?
          log_error "Start spot not defined" unless spot
          user = User.find(:first, :conditions => {:email_address => "rsx_mobile_service@local.loc"})
          spotting = Spotting.create! :spotting_time => time, :spot => spot, :boat => boat, :spotter => user
          spotting.save!
        elsif flagname.eql? "finish"
          log_info "Finishing the race of boat #{boat_id}"
          fleet_race.end_time = time 
          fleet_race.save!
          spot = fleet_race.course.spots.first :conditions => {:spot_type => Spot::SpotType::FINISH}
          log_error "Finish spot not defined" unless spot
          user = User.find(:first, :conditions => {:email_address => "rsx_mobile_service@local.loc"})
          spotting = Spotting.create! :spotting_time => time, :spot => spot, :boat => boat, :spotter => user
          spotting.save!
        else
          log_error "Unsupported flag: #{flagname}"
        end
      end
      
      # Initialize spot type on whether or not a start time is given
      # If the time is bigger or equal to the fleet race's start time, it is a REPORT, otherwise, it is a MARK
      spot_type = if fleet_race.start_time and time >= fleet_race.start_time; Spot::SpotType::MARK; else; Spot::SpotType::REPORT; end
      conditions = {:spot_type => spot_type}
      conditions[:position] = buoy if spot_type == Spot::SpotType::MARK
      spot = fleet_race.course.spots.first :conditions => conditions
      log_info "Spot     : #{spot}"
      log_error "No spot defined" and return unless spot
      user = User.find(:first, :conditions => {:email_address => "rsx_mobile_service@local.loc"})
      spotting = Spotting.create! :spotting_time => time, :spot => spot, :boat => boat, :spotter => user
      spotting.save!
      log_info "Spotting : #{spotting}"
    end
    
    def start
      log_info "Starting"
      @doc = open_xml
      return unless @doc
      
      rms = RsxMobileService.find @rsx_mobile_service_id
      
      log_error "No RSX Mobile Service Object" and return unless rms
      
      ActiveRecord::Base.transaction do
        @doc.xpath('//position-update/position').each do |position|
          begin
            perform_update position, rms.event
          rescue Exception => e
            log_error e.message
          end
        end
      end
    end
    
    def self.perform rsx_mobile_service_id, unpacked
      xml = $SECURITY[:rsx_mobile_service].decrypt unpacked.pack("C*")
      pu = PositionUpdate.new rsx_mobile_service_id, xml
      pu.start
    end

  end
end
