class CountrySeed
  # This really is a singleton thing
  include Singleton
  
  
  # Performs seeding the country table, using the comtrade webservices of the UN.
  def perform
    doc = Nokogiri::XML.parse Net::HTTP.get "comtrade.un.org", "/ws/refs/getCountryList.aspx"
    
    # For each country, perform an update
    info "==== Updating Countries"
    
    ActiveRecord::Base.transaction do
      doc.xpath("/Country/r").each { |r| 
        update HTMLEntities.new.decode(r.xpath("name/text()")), HTMLEntities.new.decode(r.xpath("iso3/text()"))
      }
    end    
  end
  
  private
  
  # Log and if available output logging
  def info s
    puts s
    RAILS_DEFAULT_LOGGER.info s
  end
  
  # Updates the country, creating it if it doesn't exist yet.
  # NOTE: No deletion is performed, as former countries might still be proper for historical races. This
  #       might best be done by the administrator
  def update name, code
    # If there is node code, it should be similar to the name
    code = name if code == nil || code.empty?
    
    info "-- #{name} (#{code})"
    c = Country.find_by_code(code)
    if c
      c.name = name
      c.save!
    else
      Country.create :name => name, :code => code
    end
  end
  
end
