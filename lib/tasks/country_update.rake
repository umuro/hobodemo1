namespace :app do

  desc 'Update and remove countries in database'
  task :update_countries => [:environment] do

    countries do |name, code|
      code = name if code == nil || code.empty?

      #differently named countries that are actually the same country 
      #share the same code, e.g. Belgium-Luxembourg and Belgium have BEL
      country = Country.find_by_code(code)
      if country
        puts "--- updating: #{country.name} ---> #{name}"
        country.name = name
        country.save
      end
    end

    #remove all countries which match the regex
    Country.all.each do |country|
      if country.name =~ /\bnes|fmr|before \d{4}|special categories\b/i
	country.delete
# 	if country.user_profiles.blank? && country.enrollments.blank?
# 	  country.delete
# 	else
# 	  puts "Country should not be in use #{country.to_yaml}"
# 	end
      end
    end

    puts "orphan user_profiles: #{UserProfile.find(:all, :conditions=>{:country_id=>nil}).count}"
    puts "  orphan enrollments: #{Enrollment.find(:all, :conditions=>{:country_id=>nil}).count}"

    c = Country.find_by_name "Belgium-Luxembourg"
    if c
      c.name = "Belgium"
      c.save!
    end
  end

  #return the list of countries with nonsense filtered out
  def countries
    doc = Nokogiri::XML.parse Net::HTTP.get "comtrade.un.org", "/ws/refs/getCountryList.aspx"
    
    decoder = HTMLEntities.new

    #skipping criteria list
    #nes: not elsewhere specified, e.g. Rest of America, nes
    #belgium-luxembourg
    #frm: former, e.g. Fmr Dem. Rep. of Germany
    #before <year>, e.g. USA (before 1981) (USA)
    #special categories
    skip_list = /\bnes|belgium-luxembourg|fmr|before \d{4}|special categories\b/i

    ActiveRecord::Base.transaction do
      doc.xpath("/Country/r").each { |r|

        name = decoder.decode(r.xpath("name/text()"))
        code = decoder.decode(r.xpath("iso3/text()"))

        yield name, code unless name =~ skip_list
      }
    end    
  end

end